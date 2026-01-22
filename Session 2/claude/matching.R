# ==============================================================================
# Matching Methods for Causal Inference
# Companion to experiments.R - Addressing Confounding Without Randomization
# ==============================================================================
#
# In experiments.R, we saw that randomization solves the confounding problem by
# making treatment assignment independent of confounders. But what if we can't
# randomize? Matching methods attempt to create a "pseudo-experiment" from
# observational data by finding treated and control units that are similar on
# observed characteristics.
#
# KEY INSIGHT: Matching can only address OBSERVED confounding. If there are
# unobserved confounders (like 'w' in our DGP), matching on observed variables
# alone won't fully remove bias. This is a fundamental limitation!
# ==============================================================================

# ------------------------------------------------------------------------------
# Install packages (uncomment if needed)
# ------------------------------------------------------------------------------
# install.packages("Matching")
# install.packages("MatchIt")
# install.packages("cobalt")
# install.packages("tidyverse")
# install.packages("ggplot2")

# Load libraries
library(Matching)    # For Match(), GenMatch(), MatchBalance()
library(MatchIt)     # For matchit() and coarsened exact matching
library(cobalt)      # For love plots and balance assessment
library(tidyverse)   # For data manipulation (dplyr, ggplot2, etc.)
library(ggplot2)     # For visualization

# Set seed for reproducibility
set.seed(123)


# ==============================================================================
# PART 1: DATA GENERATION
# ==============================================================================
# We use the EXACT same data generating process as experiments.R so students
# can directly compare how matching addresses the same confounding problem
# that randomization solves.
# ------------------------------------------------------------------------------

# Sample size
n <- 900

# ------------------------------------------------------------------------------
# 1.1 Generate Confounders
# ------------------------------------------------------------------------------
# w = UNOBSERVED confounder (binary: 0 or 1)
#     In real life, we wouldn't know this exists!
#     Examples: innate ability, motivation, genetic factors
#
# z = OBSERVED confounder (continuous, mean = 5)
#     This is what we can actually measure and match on
#     Examples: age, income, pre-treatment test scores
# ------------------------------------------------------------------------------

w <- sample(c(0, 1), n, replace = TRUE)  # Unobserved - we pretend not to know this
z <- rnorm(n = n, mean = 5)              # Observed - this we can use for matching


# -- SIDE QUEST ---

# --- How do they look like? ---

# let's make a df
df <- data.frame(w = w, z = z)


# ------------------------------------------------------------------------------
# 1.2 Generate Treatment (CONFOUNDED assignment)
# ------------------------------------------------------------------------------
# Treatment depends on BOTH confounders:
# - Higher w (unobserved) -> more likely to be treated
# - Higher z (observed) -> more likely to be treated
#
# This creates selection bias: treated units are systematically different
# from control units BEFORE treatment even happens.
# ------------------------------------------------------------------------------

Tstar <- 3 * w + z + rnorm(n = n)        # Latent var
Treat <- ifelse(Tstar > 6.5, 1, 0)       # Treatment assignment (binary)

# Check treatment proportions
cat("Treatment proportions:\n")
table(Treat)
prop.table(table(Treat))

# ------------------------------------------------------------------------------
# 1.3 Generate Outcome
# ------------------------------------------------------------------------------
# TRUE CAUSAL EFFECT = 2 (this is what we want to recover!)
#
# Y = 2*Treatment + 2*w + z + noise
#
# The outcome depends on:
#   - Treatment (causal effect = 2)
#   - w (unobserved confounder, effect = 2)
#   - z (observed confounder, effect = 1)
#   - Random noise
# ------------------------------------------------------------------------------

y <- 2 * Treat + 2 * w + z + rnorm(n = n)

# ------------------------------------------------------------------------------
# 1.4 Create Observational Dataset
# ------------------------------------------------------------------------------
# In real life, we would only observe: y, Treat, z
# We would NOT observe w (but we keep it for checking our methods)
# ------------------------------------------------------------------------------

obsData <- data.frame(
  y = y,
  Treat = Treat,
  z = z,
  w = w  # We keep this for validation, but pretend we can't use it
)

# Quick look at the data
nrow(obsData)
head(obsData)
summary(obsData)


# ------------------------------------------------------------------------------
# 1.4.a Treatment Assignment (Selection Check)
# ------------------------------------------------------------------------------
# If treatment were random, counts would be roughly balanced.
# Here imbalance is expected because Treat depends on Tstar.

ggplot(obsData, aes(x = factor(Treat))) +
  geom_bar(fill = "darkgreen") +
  labs(
    title = "1.4.a Treatment Assignment (Observational Data)",
    x = "Treat (0 = Control, 1 = Treated)",
    y = "Count"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.4.b Covariate z by Treatment
# ------------------------------------------------------------------------------
# Differences here indicate selection on observables.
# z influences treatment via the latent index Tstar.

ggplot(obsData, aes(x = factor(Treat), y = z)) +
  geom_boxplot(fill = "skyblue") +
  labs(
    title = "1.4.b Covariate z by Treatment Status",
    x = "Treat",
    y = "z"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.4.c Distribution of z by Treatment (Common Support)
# ------------------------------------------------------------------------------
# Limited overlap means extrapolation risk in causal estimation.

ggplot(obsData, aes(x = z, fill = factor(Treat))) +
  geom_density(alpha = 0.5) +
  labs(
    title = "1.4.c Distribution of z by Treatment",
    fill = "Treat"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.4.d Outcome y by Treatment (Naïve Comparison)
# ------------------------------------------------------------------------------
# This difference mixes:
#   - true treatment effect
#   - effect of unobserved w
#   - effect of z
# Therefore it is NOT causal.

ggplot(obsData, aes(x = factor(Treat), y = y)) +
  geom_boxplot(fill = "orange") +
  labs(
    title = "1.4.d Outcome y by Treatment (Naïve Comparison)",
    x = "Treat",
    y = "y"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.4.e Outcome vs Covariate by Treatment
# ------------------------------------------------------------------------------
# Shows how y varies with z within each treatment group.
# Helps build intuition for regression adjustment.

ggplot(obsData, aes(x = z, y = y, color = factor(Treat))) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "1.4.e Outcome vs Covariate by Treatment",
    x = "z",
    y = "y",
    color = "Treat"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.4.f Latent Selection Variable (Simulation Insight Only)
# ------------------------------------------------------------------------------
# Tstar is NOT observable in real data.
# This plot exists only to verify how selection into treatment works.

latent <- data.frame(
  Tstar = Tstar,
  Treat = Treat,
  y = y
)

ggplot(latent, aes(x = Tstar, y = y, color = factor(Treat))) +
  geom_point(alpha = 0.5) +
  geom_vline(xintercept = 6.5, linetype = "dashed") +
  labs(
    title = "1.4.f Latent Selection Variable and Outcome",
    subtitle = "Dashed line = treatment threshold",
    color = "Treat"
  ) +
  theme_minimal()



# ------------------------------------------------------------------------------
# 1.5 Generate Experimental Benchmark (for comparison)
# ------------------------------------------------------------------------------
# What would we get if we could actually randomize?
# This gives us the "gold standard" to compare our matching results against.
# ------------------------------------------------------------------------------

treatExp <- sample(c(0, 1), n, replace = TRUE)  # Random assignment
yExp <- 2 * treatExp + 2 * w + z + rnorm(n = n)

expData <- data.frame(
  y = yExp,
  Treat = treatExp,
  z = z,
  w = w
)

# Experimental estimate (should be close to 2)
expModel <- lm(y ~ Treat, data = expData)

summary(expModel)

cat("\n--- Experimental Benchmark ---\n")
cat("Estimated effect:", round(coef(expModel)["Treat"], 3), "\n")
cat("(True effect is 2)\n")



# GRAPHS

# ------------------------------------------------------------------------------
# 1.5.1.a Treatment Assignment (Balance Check)
# ------------------------------------------------------------------------------

ggplot(expData, aes(x = factor(Treat))) +
  geom_bar(fill = "darkgreen") +
  labs(
    title = "1.5.1.a Treatment Assignment (Randomized)",
    x = "Treat (0 = Control, 1 = Treated)",
    y = "Count"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.5.1.b Covariate Balance: z by Treatment
# ------------------------------------------------------------------------------

ggplot(expData, aes(x = factor(Treat), y = z)) +
  geom_boxplot(fill = "skyblue") +
  labs(
    title = "1.5.1.b Covariate z by Treatment",
    subtitle = "Random assignment ⇒ similar distributions",
    x = "Treat",
    y = "z"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.5.1.c Common Support: Density of z by Treatment
# ------------------------------------------------------------------------------

ggplot(expData, aes(x = z, fill = factor(Treat))) +
  geom_density(alpha = 0.5) +
  labs(
    title = "1.5.1.c Distribution of z by Treatment",
    fill = "Treat"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.5.1.d Outcome by Treatment (Causal Difference)
# ------------------------------------------------------------------------------

ggplot(expData, aes(x = factor(Treat), y = y)) +
  geom_boxplot(fill = "orange") +
  labs(
    title = "1.5.1.d Outcome y by Treatment",
    subtitle = "Difference reflects causal effect",
    x = "Treat",
    y = "y"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 1.5.1.e Outcome vs Covariate by Treatment
# ------------------------------------------------------------------------------

ggplot(expData, aes(x = z, y = y, color = factor(Treat))) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "1.5.1.e Outcome vs Covariate (Experimental Data)",
    x = "z",
    y = "y",
    color = "Treat"
  ) +
  theme_minimal()


# ==============================================================================
# PART 2: THE CONFOUNDING PROBLEM (Motivation for Matching)
# ==============================================================================
# Before we start matching, let's see why we need it.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# 2.1 Naive Regression (Biased!)
# ------------------------------------------------------------------------------
# If we just compare treated vs control outcomes, we get a biased estimate
# because treated units were already different (higher z and w) before treatment.
# ------------------------------------------------------------------------------

naiveModel <- lm(y ~ Treat, data = obsData)

cat("\n--- Naive Comparison (Biased) ---\n")
summary(naiveModel)

cat("\nEstimated effect:", round(coef(naiveModel)["Treat"], 3))
cat("\nBias:", round(coef(naiveModel)["Treat"] - 2, 3), "\n")

# ------------------------------------------------------------------------------
# 2.2 Regression Controlling for Observed Confounder
# ------------------------------------------------------------------------------
# Adding z helps, but we still can't control for w (unobserved)!
# ------------------------------------------------------------------------------

controlledModel <- lm(y ~ Treat + z, data = obsData)
cat("\n--- Controlling for z (still biased due to w) ---\n")
summary(controlledModel)
cat("\nEstimated effect:", round(coef(controlledModel)["Treat"], 3))
cat("\nBias:", round(coef(controlledModel)["Treat"] - 2, 3), "\n")

# If we could control for w (which we can't in real life):
fullModel <- lm(y ~ Treat + z + w, data = obsData)
cat("\n--- If we could control for w (not realistic) ---\n")
cat("Estimated effect:", round(coef(fullModel)["Treat"], 3))
cat("\n(This shows what's possible if we knew all confounders)\n")


# ==============================================================================
# PART 3: EXACT MATCHING AND COARSENED EXACT MATCHING
# ==============================================================================
# The simplest matching idea: find control units that are EXACTLY the same
# as treated units on all observed covariates.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# 3.1 The Curse of Dimensionality Problem
# ------------------------------------------------------------------------------
# Exact matching works great with a few categorical variables.
# But with continuous variables (like z), exact matches are nearly impossible!
# ------------------------------------------------------------------------------

# Try to find exact matches on z (rounded to integers for illustration)
obsData$zRounded <- round(obsData$z)

# How many unique values of rounded z?
cat("\n--- Exact Matching Problem ---\n")
cat("Unique values of z (rounded):", length(unique(obsData$zRounded)), "\n")

# Cross-tabulate treatment by z values
table(obsData$Treat, obsData$zRounded)

# With more covariates, this problem gets exponentially worse.
# This is the "curse of dimensionality."

# ------------------------------------------------------------------------------
# 3.2 Coarsened Exact Matching (CEM)
# ------------------------------------------------------------------------------
# IDEA: Instead of exact matching, we "coarsen" (bin) continuous variables
# into categories, then match exactly within those categories.
#
# Trade-off:
#   - More coarsening -> more matches, but worse within-category balance
#   - Less coarsening -> fewer matches, but better balance
#
# This is an example of the bias-variance tradeoff in matching!
# ------------------------------------------------------------------------------

# Use MatchIt package for CEM
# method = "cem" = Coarsened Exact Matching
# cutpoints = list(z = 5) means: split z into 5 equal-width bins

cemMatch <- matchit(
  Treat ~ z,                    # Match on z (treatment ~ covariates)
  data = obsData,
  method = "cem",               # Coarsened Exact Matching
  cutpoints = list(z = 5)       # Create 5 bins for z
)

# Summary of matching
summary(cemMatch)

# What did CEM do?
# It created bins of z and matched treated/control units within the same bin.
# Units without a match in their bin are discarded.

# Extract matched data
cemData <- match.data(cemMatch)
# match.data() returns only the matched observations with weights

cat("\n--- CEM Results ---\n")
cat("Original sample size:", nrow(obsData), "\n")
cat("Matched sample size:", nrow(cemData), "\n")
cat("Observations discarded:", nrow(obsData) - nrow(cemData), "\n")

# Estimate effect using matched data
# Note: We use weights because CEM may weight observations differently
cemModel <- lm(y ~ Treat, data = cemData, weights = weights)
summary(cemModel)

cat("\nEstimated effect (CEM):", round(coef(cemModel)["Treat"], 3))
cat("\nBias:", round(coef(cemModel)["Treat"] - 2, 3), "\n")


# ==============================================================================
# PART 4: PROPENSITY SCORE MATCHING
# ==============================================================================
# Instead of matching on all covariates directly, we match on a single number:
# the PROPENSITY SCORE = P(Treatment = 1 | Covariates)
#
# This is the probability of receiving treatment given observed characteristics.
# Rosenbaum & Rubin (1983) showed this reduces the dimensionality problem.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# 4.1 Estimate Propensity Scores
# ------------------------------------------------------------------------------
# We use logistic regression to estimate P(Treat = 1 | z)
# In real applications, you might include many more covariates.
# ------------------------------------------------------------------------------

# Logistic regression: predict treatment from covariates
psModel <- glm(Treat ~ z, data = obsData, family = binomial(link = "logit"))
summary(psModel)

# Extract propensity scores (predicted probabilities)
obsData$pscore <- predict(psModel, type = "response")
# type = "response" gives probabilities (not log-odds)

# Visualize propensity score distributions
ggplot(obsData, aes(x = pscore, fill = factor(Treat))) +
  geom_histogram(alpha = 0.5, position = "identity", bins = 30) +
  labs(title = "Propensity Score Distributions",
       x = "Propensity Score (P(Treat=1|z))",
       y = "Count",
       fill = "Treatment") +
  theme_minimal() +
  scale_fill_manual(values = c("0" = "blue", "1" = "red"),
                    labels = c("Control", "Treated"))

# Notice: Treated units have higher propensity scores (as expected, since
# higher z -> higher probability of treatment in our DGP)

# ------------------------------------------------------------------------------
# 4.2 Propensity Score Matching with Matching Package
# ------------------------------------------------------------------------------
# The Match() function finds matches based on a matching variable (propensity score)
#
# KEY PARAMETERS (default values and what they mean):
#
# estimand = "ATT" (default)
#   - "ATT" = Average Treatment effect on the Treated
#             Finds controls that match to treated units
#             Asks: "What was the effect for those who were treated?"
#   - "ATE" = Average Treatment Effect (population average)
#             Matches in both directions (treated to controls AND controls to treated)
#             Asks: "What would be the effect if we treated everyone?"
#   - "ATC" = Average Treatment effect on the Controls
#             Finds treated that match to control units
#             Asks: "What would have been the effect if controls had been treated?"
#
# replace = TRUE (default)
#   - TRUE = Matching WITH replacement
#            A control can be matched to multiple treated units
#            Better matches, but reduces effective sample size
#   - FALSE = Matching WITHOUT replacement
#             Each control used at most once
#             More observations, but potentially worse matches
#
# M = 1 (default)
#   - Number of control matches per treated unit
#   - M = 1 is "1-to-1 matching"
#   - Higher M uses more data but may include worse matches
#
# caliper = NULL (default, no caliper)
#   - Maximum allowed distance between matched units
#   - Prevents bad matches but may discard observations
#   - Specified in standard deviations of the matching variable
# ------------------------------------------------------------------------------

# Perform propensity score matching
# We use the Matching package's Match() function

psmResult <- Match(
  Y = obsData$y,           # Outcome variable
  Tr = obsData$Treat,      # Treatment indicator (1 = treated, 0 = control)
  X = obsData$pscore,      # Matching variable (propensity score)
  estimand = "ATT",         # Average Treatment effect on the Treated
  replace = TRUE,           # Allow matching with replacement (control vars can be used multiple times)
  M = 1                     # 1-to-1 matching
)

# Display results
summary(psmResult)

cat("\n--- Propensity Score Matching Results ---\n")
cat("Estimated ATT:", round(psmResult$est, 3), "\n")
cat("Standard Error:", round(psmResult$se, 3), "\n")
cat("Bias (from true effect of 2):", round(psmResult$est - 2, 3), "\n")

# Note: The estimate is still biased because we can only match on z (observed),
# not on w (unobserved). This is the fundamental limitation of matching!


# ==============================================================================
# SIDEBAR: UNDERSTANDING STANDARDIZATION
# ==============================================================================
# Before we discuss "Standardized Mean Difference" in balance assessment,
# let's make sure we understand what standardization means and why it matters.
#
# This is a foundational concept that appears throughout statistics!
# ==============================================================================

# ------------------------------------------------------------------------------
# What is Standardization?
# ------------------------------------------------------------------------------
# Standardization (also called "z-score normalization") transforms a variable
# so that it has:
#   - Mean = 0
#   - Standard Deviation = 1
#
# THE FORMULA:
#   z = (x - mean(x)) / sd(x)
#
# For each observation:
#   1. Subtract the mean (centers the data at 0)
#   2. Divide by the standard deviation (scales to unit variance)
#
# WHY DO WE STANDARDIZE?
# ----------------------
# 1. COMPARABILITY: Different variables have different units and scales
#    - Age might range from 18-80 (years)
#    - Income might range from 20,000-500,000 (dollars)
#    - Test scores might range from 0-100 (points)
#
#    After standardization, ALL variables are on the same scale!
#    A value of 1 means "1 standard deviation above the mean" regardless
#    of whether we're talking about age, income, or test scores.
#
# 2. INTERPRETATION: Standardized values tell us "how unusual" a value is
#    - z = 0: exactly at the mean
#    - z = 1: one SD above the mean (about 84th percentile if normal)
#    - z = 2: two SDs above the mean (about 97.7th percentile if normal)
#    - z = -1: one SD below the mean (about 16th percentile if normal)
#
# 3. BALANCE ASSESSMENT: In matching, we use Standardized Mean Difference (SMD)
#    because it lets us compare balance across variables with different scales.
#    An SMD of 0.1 means "the groups differ by 0.1 standard deviations"
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Let's See Standardization in Action
# ------------------------------------------------------------------------------

# Create example data with variables on VERY different scales
set.seed(42)
nExample <- 200

# Age: measured in years (range roughly 20-70)
age <- rnorm(nExample, mean = 45, sd = 12)

# Income: measured in dollars (range roughly 30k-150k)
income <- rnorm(nExample, mean = 75000, sd = 25000)

# Test score: measured in points (range roughly 50-100)
testScore <- rnorm(nExample, mean = 75, sd = 10)

# Combine into a data frame
exampleData <- data.frame(
  age = age,
  income = income,
  testScore = testScore
)

# Look at the summary - notice the VERY different scales!
cat("\n--- Original Variables (Different Scales) ---\n")
summary(exampleData)

cat("\nStandard Deviations:\n")
cat("  Age:       ", round(sd(exampleData$age), 2), "years\n")
cat("  Income:    ", round(sd(exampleData$income), 2), "dollars\n")
cat("  Test Score:", round(sd(exampleData$testScore), 2), "points\n")

# ------------------------------------------------------------------------------
# Manual Standardization (to understand the formula)
# ------------------------------------------------------------------------------

# Standardize age manually using the formula: z = (x - mean) / sd
ageStandardized <- (exampleData$age - mean(exampleData$age)) / sd(exampleData$age)

# Verify: mean should be ~0, sd should be ~1
cat("\n--- Manual Standardization of Age ---\n")
cat("Original Age - Mean:", round(mean(exampleData$age), 2),
    "SD:", round(sd(exampleData$age), 2), "\n")
cat("Standardized - Mean:", round(mean(ageStandardized), 6),
    "SD:", round(sd(ageStandardized), 6), "\n")

# ------------------------------------------------------------------------------
# Using R's scale() Function (the easy way!)
# ------------------------------------------------------------------------------
# R has a built-in function called scale() that standardizes variables
# scale(x) returns a matrix, so we often use as.numeric() or [,1] to get a vector

exampleData$ageStd <- scale(exampleData$age)[,1]
exampleData$incomeStd <- scale(exampleData$income)[,1]
exampleData$testScoreStd <- scale(exampleData$testScore)[,1]

# Now all standardized variables have mean=0 and sd=1
cat("\n--- All Variables After Standardization ---\n")
cat("Age (std)       - Mean:", round(mean(exampleData$ageStd), 6),
    "SD:", round(sd(exampleData$ageStd), 6), "\n")
cat("Income (std)    - Mean:", round(mean(exampleData$incomeStd), 6),
    "SD:", round(sd(exampleData$incomeStd), 6), "\n")
cat("Test Score (std)- Mean:", round(mean(exampleData$testScoreStd), 6),
    "SD:", round(sd(exampleData$testScoreStd), 6), "\n")

# ------------------------------------------------------------------------------
# Visualizing Standardization with ggplot2
# ------------------------------------------------------------------------------

# First, let's see the ORIGINAL distributions (different scales)
# We need to reshape data for ggplot - create separate data frames and combine

# Original data (different scales - hard to compare on same plot!)
plotOriginal <- data.frame(
  value = c(exampleData$age, exampleData$income/1000, exampleData$testScore),
  variable = rep(c("Age (years)", "Income ($1000s)", "Test Score (points)"),
                 each = nExample)
)

pOriginal <- ggplot(plotOriginal, aes(x = value, fill = variable)) +
  geom_histogram(alpha = 0.6, bins = 25, position = "identity") +
  facet_wrap(~variable, scales = "free_x", ncol = 1) +
  labs(
    title = "Original Variables: Different Scales",
    subtitle = "Each variable has its own mean and spread - hard to compare directly",
    x = "Value (in original units)",
    y = "Count"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  scale_fill_brewer(palette = "Set2")

print(pOriginal)

# Now let's see the STANDARDIZED distributions (same scale!)
plotStandardized <- data.frame(
  value = c(exampleData$ageStd, exampleData$incomeStd, exampleData$testScoreStd),
  variable = rep(c("Age (standardized)", "Income (standardized)",
                   "Test Score (standardized)"), each = nExample)
)

pStandardized <- ggplot(plotStandardized, aes(x = value, fill = variable)) +
  geom_histogram(alpha = 0.6, bins = 25, position = "identity") +
  facet_wrap(~variable, ncol = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", size = 0.8) +
  labs(
    title = "Standardized Variables: Same Scale!",
    subtitle = "All centered at 0, all have SD = 1 - now directly comparable",
    x = "Standardized Value (z-score)",
    y = "Count"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  scale_fill_brewer(palette = "Set2") +
  xlim(-4, 4)

print(pStandardized)

# ------------------------------------------------------------------------------
# Overlay Plot: All Standardized Variables Together
# ------------------------------------------------------------------------------
# Now we can meaningfully plot all variables on the same axis!

pOverlay <- ggplot(plotStandardized, aes(x = value, color = variable, fill = variable)) +
  geom_density(alpha = 0.3, size = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", size = 0.8) +
  geom_vline(xintercept = c(-1, 1), linetype = "dotted", color = "gray50", size = 0.5) +
  geom_vline(xintercept = c(-2, 2), linetype = "dotted", color = "gray70", size = 0.5) +
  annotate("text", x = 0, y = 0, label = "Mean", vjust = -0.5, size = 3) +
  annotate("text", x = 1, y = 0, label = "+1 SD", vjust = -0.5, size = 2.5, color = "gray50") +
  annotate("text", x = -1, y = 0, label = "-1 SD", vjust = -0.5, size = 2.5, color = "gray50") +
  labs(
    title = "All Standardized Variables on the Same Scale",
    subtitle = "Standardization allows direct comparison across different measurements",
    x = "Standardized Value (z-score)",
    y = "Density",
    color = "Variable",
    fill = "Variable"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_color_brewer(palette = "Set2") +
  scale_fill_brewer(palette = "Set2") +
  xlim(-4, 4)

print(pOverlay)

# ------------------------------------------------------------------------------
# Interpreting Standardized Values
# ------------------------------------------------------------------------------

# Let's pick a specific person and interpret their standardized scores
cat("\n--- Interpreting Standardized Scores for Person #1 ---\n")
cat("Original values:\n")
cat("  Age:", round(exampleData$age[1], 1), "years\n")
cat("  Income: $", format(round(exampleData$income[1]), big.mark = ","), "\n", sep = "")
cat("  Test Score:", round(exampleData$testScore[1], 1), "points\n")

cat("\nStandardized values (z-scores):\n")
cat("  Age:", round(exampleData$ageStd[1], 2), "\n")
cat("  Income:", round(exampleData$incomeStd[1], 2), "\n")
cat("  Test Score:", round(exampleData$testScoreStd[1], 2), "\n")

cat("\nInterpretation:\n")
if (exampleData$ageStd[1] > 0) {
  cat("  Age: ", round(exampleData$ageStd[1], 2), " SDs ABOVE average\n", sep = "")
} else {
  cat("  Age: ", round(abs(exampleData$ageStd[1]), 2), " SDs BELOW average\n", sep = "")
}
if (exampleData$incomeStd[1] > 0) {
  cat("  Income: ", round(exampleData$incomeStd[1], 2), " SDs ABOVE average\n", sep = "")
} else {
  cat("  Income: ", round(abs(exampleData$incomeStd[1]), 2), " SDs BELOW average\n", sep = "")
}
if (exampleData$testScoreStd[1] > 0) {
  cat("  Test Score: ", round(exampleData$testScoreStd[1], 2), " SDs ABOVE average\n", sep = "")
} else {
  cat("  Test Score: ", round(abs(exampleData$testScoreStd[1]), 2), " SDs BELOW average\n", sep = "")
}

# ------------------------------------------------------------------------------
# Connection to Balance Assessment: Standardized Mean Difference (SMD)
# ------------------------------------------------------------------------------
# Now we can understand why SMD is so useful!
#
# When comparing treated vs control groups:
#   SMD = (mean_treated - mean_control) / pooled_SD
#
# This is EXACTLY the same logic as z-scores, applied to the difference
# between group means!
#
# An SMD of 0.1 means:
#   "The treated group's mean is 0.1 standard deviations higher/lower
#    than the control group's mean"
#
# This works regardless of whether the variable is age (in years),
# income (in dollars), or test scores (in points)!
# ------------------------------------------------------------------------------

# Let's demonstrate SMD with our matching data

# Split z into "treated" and "control" groups (from our actual matching data)
zTreated <- obsData$z[obsData$Treat == 1]
zControl <- obsData$z[obsData$Treat == 0]

# Calculate SMD manually
meanTreated <- mean(zTreated)
meanControl <- mean(zControl)

# Pooled standard deviation (there are slightly different formulas; this is common)
pooledSd <- sqrt((var(zTreated) + var(zControl)) / 2)

smdManual <- (meanTreated - meanControl) / pooledSd

cat("\n--- Standardized Mean Difference (SMD) for z ---\n")
cat("Mean (Treated):", round(meanTreated, 3), "\n")
cat("Mean (Control):", round(meanControl, 3), "\n")
cat("Raw Difference:", round(meanTreated - meanControl, 3), "\n")
cat("Pooled SD:", round(pooledSd, 3), "\n")
cat("SMD:", round(smdManual, 3), "\n")

cat("\nInterpretation:\n")
cat("The treated group has a z-value that is", round(abs(smdManual), 2),
    "standard deviations", ifelse(smdManual > 0, "HIGHER", "LOWER"),
    "than the control group.\n")

if (abs(smdManual) < 0.1) {
  cat("SMD < 0.1: EXCELLENT balance!\n")
} else if (abs(smdManual) < 0.25) {
  cat("SMD < 0.25: Acceptable balance.\n")
} else {
  cat("SMD > 0.25: POOR balance - groups are quite different!\n")
}

# ------------------------------------------------------------------------------
# Visualize SMD: Before vs After Matching
# ------------------------------------------------------------------------------

# Create visualization comparing distributions
smdPlotData <- data.frame(
  z = c(zTreated, zControl),
  group = c(rep("Treated", length(zTreated)), rep("Control", length(zControl)))
)

pSmd <- ggplot(smdPlotData, aes(x = z, fill = group)) +
  geom_density(alpha = 0.5, size = 1) +
  geom_vline(xintercept = meanTreated, color = "red", linetype = "dashed", size = 1) +
  geom_vline(xintercept = meanControl, color = "blue", linetype = "dashed", size = 1) +
  annotate("segment", x = meanControl, xend = meanTreated,
           y = 0.35, yend = 0.35,
           arrow = arrow(ends = "both", length = unit(0.1, "inches")),
           color = "black", size = 1) +
  annotate("text", x = (meanTreated + meanControl)/2, y = 0.38,
           label = paste0("SMD = ", round(smdManual, 2)), size = 4, fontface = "bold") +
  labs(
    title = "Visualizing Standardized Mean Difference (SMD)",
    subtitle = paste0("Before matching: Groups differ by ", round(abs(smdManual), 2),
                     " standard deviations"),
    x = "z (observed confounder)",
    y = "Density",
    fill = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_fill_manual(values = c("Control" = "blue", "Treated" = "red"))

print(pSmd)

# Clean up example variables (keep obsData intact)
rm(age, income, testScore, nExample, ageStandardized)
rm(plotOriginal, plotStandardized, pOriginal, pStandardized, pOverlay)
rm(zTreated, zControl, meanTreated, meanControl, pooledSd, smdManual, smdPlotData, pSmd)



# ==============================================================================
# PART 5: BALANCE ASSESSMENT (CRITICAL FOR MATCHING!)
# ==============================================================================
# Matching is only as good as the balance it achieves.
# We need to check: Are treated and control groups similar AFTER matching?
#
# "Balance" means the covariate distributions are similar between groups.
# If balance is good, we've created a pseudo-experiment.
# If balance is poor, our estimate may still be biased.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# 5.1 MatchBalance() Function - Comprehensive Balance Statistics
# ------------------------------------------------------------------------------
# MatchBalance() from the Matching package provides detailed balance diagnostics.
# Let's examine what each statistic means.
# ------------------------------------------------------------------------------

# Check balance BEFORE matching (on the original data)
cat("\n" , rep("=", 70), "\n")
cat("BALANCE BEFORE MATCHING\n")
cat(rep("=", 70), "\n\n")

balanceBefore <- MatchBalance(
  Treat ~ z,                    # Formula: Treatment ~ Covariates to check
  data = obsData,
  nboots = 500                  # Number of bootstrap replications for KS test
)

# Now check balance AFTER propensity score matching
cat("\n", rep("=", 70), "\n")
cat("BALANCE AFTER PROPENSITY SCORE MATCHING\n")
cat(rep("=", 70), "\n\n")

balanceAfter <- MatchBalance(
  Treat ~ z,
  data = obsData,
  match.out = psmResult,       # Pass the matching result
  nboots = 500
)

# ------------------------------------------------------------------------------
# 5.2 Understanding MatchBalance() Output - DETAILED EXPLANATION
# ------------------------------------------------------------------------------
#
# For each covariate, MatchBalance() reports:
#
# MEAN STATISTICS:
# ----------------
# "mean treatment" / "mean control" = Average values in each group
#   - Want these to be similar after matching
#
# "std mean diff" (Standardized Mean Difference, SMD)
#   - Formula: (meanTreated - meanControl) / sdPooled
#   - Scale-free measure of difference in means
#   - INTERPRETATION:
#     * |SMD| < 0.1 = Excellent balance (rule of thumb)
#     * |SMD| < 0.25 = Acceptable balance
#     * |SMD| > 0.25 = Poor balance, matching may not be working
#   - This is the MOST COMMONLY REPORTED balance statistic
#
# DISTRIBUTIONAL STATISTICS (beyond just means):
# ----------------------------------------------
# Means can be balanced while distributions differ (e.g., different variances)
# These statistics check the full distribution:
#
# "var ratio" (Variance Ratio)
#   - Formula: varTreated / varControl
#   - INTERPRETATION:
#     * = 1 means equal variances
#     * < 0.5 or > 2 suggests distributional differences
#
# "mean/med/max raw eQQ diff" (Empirical Quantile-Quantile Differences)
#   - Compares the distributions at every quantile
#   - Process: Sort treated and control values, compare at each percentile
#   - "raw" means in original units of the variable
#   - mean eQQ diff = average difference across all quantiles
#   - med eQQ diff = median difference across all quantiles
#   - max eQQ diff = largest difference at any quantile
#   - INTERPRETATION: Smaller is better; 0 = identical distributions
#
# "mean/med/max eCDF diff" (Empirical CDF Differences)
#   - Compares cumulative distribution functions
#   - At each value x, compares P(X <= x) between groups
#   - Similar to KS statistic but reported at mean/median/max
#   - INTERPRETATION: Smaller is better; 0 = identical distributions
#
# STATISTICAL TESTS:
# ------------------
# "T-test p-value"
#   - Tests null hypothesis: means are equal
#   - LIMITATION: Only tests means, assumes normality
#   - High p-value (> 0.05) suggests means are balanced
#   - WARNING: With large samples, small differences become "significant"
#
# "KS Naive p-value" (Kolmogorov-Smirnov)
#   - Tests null hypothesis: distributions are identical
#   - Based on maximum eCDF difference
#   - "Naive" = uses standard KS critical values (may be invalid after matching)
#
# "KS Statistic"
#   - The test statistic for KS test = max eCDF difference
#   - INTERPRETATION: Smaller is better; 0 = identical distributions
#
# "KS Bootstrap p-value"
#   - Bootstrap version of KS test
#   - More reliable than naive p-value because matching introduces dependence
#   - Uses permutation/bootstrap to get valid p-values
#   - High p-value suggests distributions are similar
#
# IMPORTANT NOTES ON P-VALUES:
# ----------------------------
# - P-values from balance tests should be interpreted cautiously
# - After matching, observations are NOT independent (same control may appear
#   multiple times with replacement matching)
# - The bootstrap p-value accounts for this, naive p-value does not
# - Many researchers prefer SMD over p-values because:
#   * SMD doesn't depend on sample size
#   * SMD has clear thresholds (0.1, 0.25)
#   * P-values can be "significant" even with trivial imbalance in large samples
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 5.3 The qqstats() Function - Quantile-Quantile Statistics
# ------------------------------------------------------------------------------
# qqstats() calculates the empirical QQ differences more directly.
# This helps us understand the eQQ statistics from MatchBalance().
# ------------------------------------------------------------------------------

# Get treated and control z values from the matched sample
# psmResult$index.treated gives indices of treated units used
# psmResult$index.control gives indices of their matched controls

zTreatedMatched <- obsData$z[psmResult$index.treated]
zControlMatched <- obsData$z[psmResult$index.control]

# Calculate QQ statistics
qqStats <- qqstats(zTreatedMatched, zControlMatched)
cat("\n--- QQ Statistics for z (After Matching) ---\n")
print(qqStats)

# INTERPRETATION OF qqstats() OUTPUT:
# -----------------------------------
# meandiff  = Mean of |treatedQuantile - controlQuantile| across all quantiles
#             This is the average "horizontal distance" in a QQ plot
#             Smaller = distributions are more similar
#
# mediandiff = Median of |treatedQuantile - controlQuantile|
#              More robust to outliers than meandiff
#              If mediandiff << meandiff, outliers may be causing issues
#
# maxdiff    = Maximum of |treatedQuantile - controlQuantile|
#              The worst match at any quantile
#              Identifies the part of the distribution with worst balance
#
# These correspond to the "raw eQQ diff" values in MatchBalance()


# ------------------------------------------------------------------------------
# 5.4 Love Plots - Visual Balance Assessment
# ------------------------------------------------------------------------------
# A "Love plot" (named after Thomas Love) shows standardized mean differences
# for all covariates, before and after matching, on a single graph.
#
# This makes it easy to see:
# - Which covariates improved after matching
# - Which covariates still have imbalance
# - Whether matching moved SMDs toward zero
# ------------------------------------------------------------------------------

# Create Love plot using cobalt package
# love.plot() works directly with matchit objects or Matching objects

# First, let's redo PSM using matchit for easier cobalt integration
psmMatchit <- matchit(
  Treat ~ z,
  data = obsData,
  method = "nearest",           # Nearest neighbor matching
  distance = "glm",             # Use logistic regression for propensity score
  replace = TRUE
)

# Create Love plot
love.plot(
  psmMatchit,
  binary = "std",               # Standardize binary variables too
  thresholds = c(m = 0.1),      # Add reference line at SMD = 0.1
  var.order = "unadjusted",     # Order variables by unadjusted imbalance
  title = "Love Plot: Covariate Balance Before and After PSM"
)

# READING THE LOVE PLOT:
# ----------------------
# - X-axis: Absolute Standardized Mean Difference (SMD)
#   Measures how different treated and control groups are, in SD units
#   0 = perfect balance; values closer to 0 are better
#
# - Y-axis: Variables checked for balance
#   Includes:
#     * z        : observed covariate used in matching
#     * distance : estimated propensity score (Pr[Treat = 1 | z])
#       -> not a new covariate, but the matching metric itself
#
# - Two points per variable:
#     * Unadjusted (before matching)
#     * Adjusted   (after matching)
#   Movement toward 0 indicates improved balance due to matching
#
# - Vertical dashed line at 0.1:
#     * Common rule-of-thumb threshold for acceptable balance (convention not a rule)
#     * Points to the right indicate meaningful imbalance
#
# - Interpretation goal:
#     * All "after" (adjusted) points should lie well left of 0.1
#     * Balance on both z AND distance confirms successful matching
#
# - Important caveat:
#     * Good balance here only addresses selection on observables
#     * Unobserved confounders (e.g., w) may still bias the ATT


# ------------------------------------------------------------------------------
# 5.5 Manual Balance Tests - Understanding the Statistics
# ------------------------------------------------------------------------------
# Let's implement the balance tests manually to understand what they do.
# ------------------------------------------------------------------------------

# --- T-TEST FOR COMPARING MEANS ---
# The t-test asks: Are the means significantly different?
# H0: meanTreated = meanControl
# H1: meanTreated != meanControl

cat("\n--- Manual T-Test for Balance on z ---\n")

# Before matching
tBefore <- t.test(z ~ Treat, data = obsData)
tBefore

cat("BEFORE matching:\n")
cat("  Mean (Treated):", round(mean(obsData$z[obsData$Treat == 1]), 3), "\n")
cat("  Mean (Control):", round(mean(obsData$z[obsData$Treat == 0]), 3), "\n")
cat("  Difference:", round(tBefore$estimate[1] - tBefore$estimate[2], 3), "\n")
cat("  t-statistic:", round(tBefore$statistic, 3), "\n")
cat("  p-value:", format(tBefore$p.value, scientific = TRUE, digits = 3), "\n")
# Small p-value = means are different = bad balance

# After matching
tAfter <- t.test(zTreatedMatched, zControlMatched)
tAfter

cat("\nAFTER matching:\n")
cat("  Mean (Treated):", round(mean(zTreatedMatched), 3), "\n")
cat("  Mean (Control):", round(mean(zControlMatched), 3), "\n")
cat("  Difference:", round(tAfter$estimate[1] - tAfter$estimate[2], 3), "\n")
cat("  t-statistic:", round(tAfter$statistic, 3), "\n")
cat("  p-value:", format(tAfter$p.value, scientific = TRUE, digits = 3), "\n")
# Large p-value = means are similar = good balance

# WHEN TO USE T-TEST:
# - Good for quick assessment of mean balance
# - Assumes (approximately) normal distributions
# - Only tests means, not full distribution
# - Sensitive to sample size (large samples find tiny differences "significant")


# --- KOLMOGOROV-SMIRNOV TEST FOR COMPARING DISTRIBUTIONS ---
# The KS test asks: Are the distributions significantly different?
# H0: distributions are identical
# H1: distributions differ somewhere
#
# The KS statistic = maximum vertical distance between empirical CDFs

cat("\n--- Manual Kolmogorov-Smirnov Test for Balance on z ---\n")

# Before matching
ksBefore <- ks.test(
  obsData$z[obsData$Treat == 1],
  obsData$z[obsData$Treat == 0]
)

ksBefore

cat("BEFORE matching:\n")
cat("  KS Statistic (D):", round(ksBefore$statistic, 3), "\n")
cat("  p-value:", format(ksBefore$p.value, scientific = TRUE, digits = 3), "\n")
# Small p-value = distributions differ = bad balance

# After matching
ksAfter <- ks.test(zTreatedMatched, zControlMatched)

ksAfter

cat("\nAFTER matching:\n")
cat("  KS Statistic (D):", round(ksAfter$statistic, 3), "\n")
cat("  p-value:", format(ksAfter$p.value, scientific = TRUE, digits = 3), "\n")
# Large p-value = distributions are similar = good balance

# WHEN TO USE KS TEST:
# - Tests the ENTIRE distribution, not just means
# - Non-parametric (no normality assumption needed)
# - More stringent than t-test (requires distributional similarity)
# - Can detect differences in shape, spread, or location
# - Use when you want to ensure similar distributions, not just means

# IMPORTANT: After matching with replacement, the KS test p-value from ks.test()
# is not strictly valid because matched observations are not independent.
# The bootstrap KS p-value from MatchBalance() is more appropriate.


# ------------------------------------------------------------------------------
# VISUALIZING DISTRIBUTIONS FOR KS TEST INTUITION
# ------------------------------------------------------------------------------
# The KS test compares the ENTIRE distribution of z across groups.
# Histograms and density plots help us see *why* the KS test rejects or not.

# ------------------------------------------------------------------------------
# BEFORE MATCHING: z by Treatment
# ------------------------------------------------------------------------------
# Expectation:
# - Distributions are shifted
# - KS test rejects equality of distributions

ggplot(obsData, aes(x = z, fill = factor(Treat))) +
  geom_histogram(
    bins = 30,
    alpha = 0.5,
    position = "identity"
  ) +
  labs(
    title = "Before Matching: Distribution of z by Treatment",
    subtitle = "Visible distributional differences → KS test rejects",
    x = "z",
    fill = "Treat"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# AFTER MATCHING: z by Treatment
# ------------------------------------------------------------------------------
# Construct matched dataset explicitly
# KS test and QQ statistics are based on matched observations only.

matchedData <- data.frame(
  z = c(
    obsData$z[psmResult$index.treated],
    obsData$z[psmResult$index.control]
  ),
  Treat = factor(
    c(
      rep(1, length(psmResult$index.treated)),
      rep(0, length(psmResult$index.control))
    )
  )
)

# Expectation:
# - Distributions almost perfectly overlap
# - KS test does NOT reject equality

ggplot(matchedData, aes(x = z, fill = Treat)) +
  geom_histogram(
    bins = 30,
    alpha = 0.5,
    position = "identity"
  ) +
  labs(
    title = "After Matching: Distribution of z by Treatment",
    subtitle = "Near-identical distributions → KS test does not reject",
    x = "z",
    fill = "Treat"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# DENSITY PLOTS (CLEARER VIEW OF DISTRIBUTIONAL OVERLAP)
# ------------------------------------------------------------------------------
# Density plots approximate the empirical CDFs used by the KS test.

ggplot(matchedData, aes(x = z, color = Treat)) +
  geom_density(size = 1) +
  labs(
    title = "After Matching: Density of z by Treatment",
    subtitle = "Small maximum CDF distance → small KS statistic",
    x = "z",
    color = "Treat"
  ) +
  theme_minimal()


# ------------------------------------------------------------------------------
# 5.6 Visualizing Balance: Box Plots
# ------------------------------------------------------------------------------
# Box plots are excellent for comparing distributions between groups.
# They show:
#   - Median (middle line)
#   - Interquartile range (IQR, the box: 25th to 75th percentile)
#   - Whiskers (typically 1.5 * IQR from the box)
#   - Outliers (points beyond the whiskers)
#
# For good balance: boxes should be similar in position and spread
# ------------------------------------------------------------------------------

# Create data for box plots - BEFORE matching
boxDataBefore <- data.frame(
  z = obsData$z,
  group = factor(ifelse(obsData$Treat == 1, "Treated", "Control"),
                 levels = c("Control", "Treated")),
  timing = "Before Matching"
)

# Create data for box plots - AFTER matching
boxDataAfter <- data.frame(
  z = c(zTreatedMatched, zControlMatched),
  group = factor(c(rep("Treated", length(zTreatedMatched)),
                   rep("Control", length(zControlMatched))),
                 levels = c("Control", "Treated")),
  timing = "After Matching"
)

# Combine for faceted plot
boxDataCombined <- rbind(boxDataBefore, boxDataAfter)
boxDataCombined$timing <- factor(boxDataCombined$timing,
                                  levels = c("Before Matching", "After Matching"))

# Box plot comparison
pBoxPlot <- ggplot(boxDataCombined, aes(x = group, y = z, fill = group)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21, outlier.size = 2) +
  facet_wrap(~timing) +
  labs(
    title = "Box Plot Comparison: Balance on z",
    subtitle = "Good balance = similar box positions and spreads between groups",
    x = "Group",
    y = "z (observed confounder)",
    fill = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  scale_fill_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pBoxPlot)

# INTERPRETING THE BOX PLOT:
# --------------------------
# BEFORE matching: Notice how the Treated box is shifted higher than Control
#   - This shows treated units have systematically higher z values
#   - This is the imbalance we're trying to fix!
#
# AFTER matching: The boxes should be much more aligned
#   - Similar medians = means are balanced
#   - Similar box sizes = variances are balanced
#   - Similar whisker lengths = tails are balanced

# Side-by-side box plots with individual points (for smaller samples)
pBoxPlotPoints <- ggplot(boxDataCombined, aes(x = group, y = z, fill = group)) +
  geom_boxplot(alpha = 0.5, outlier.shape = NA) +  # Hide default outliers
  geom_jitter(aes(color = group), width = 0.2, alpha = 0.3, size = 1) +  # Add all points
  facet_wrap(~timing) +
  labs(
    title = "Box Plot with Individual Observations",
    subtitle = "Jittered points show the actual data distribution",
    x = "Group",
    y = "z (observed confounder)"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  scale_fill_manual(values = c("Control" = "steelblue", "Treated" = "coral")) +
  scale_color_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pBoxPlotPoints)


# ------------------------------------------------------------------------------
# 5.7 Visualizing Balance: Histograms for Distribution Comparison
# ------------------------------------------------------------------------------
# Overlapping histograms show how the full distributions compare.
# This is what the KS test is evaluating!
#
# For good balance: histograms should overlap almost completely
# ------------------------------------------------------------------------------

# Histogram comparison - BEFORE matching
pHistBefore <- ggplot(boxDataBefore, aes(x = z, fill = group)) +
  geom_histogram(alpha = 0.5, position = "identity", bins = 30,
                 color = "white", size = 0.2) +
  geom_vline(aes(xintercept = mean(obsData$z[obsData$Treat == 1])),
             color = "coral", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = mean(obsData$z[obsData$Treat == 0])),
             color = "steelblue", linetype = "dashed", size = 1) +
  labs(
    title = "Distribution of z: BEFORE Matching",
    subtitle = "Dashed lines show group means - notice the gap!",
    x = "z (observed confounder)",
    y = "Count",
    fill = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_fill_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pHistBefore)

# Histogram comparison - AFTER matching
pHistAfter <- ggplot(boxDataAfter, aes(x = z, fill = group)) +
  geom_histogram(alpha = 0.5, position = "identity", bins = 30,
                 color = "white", size = 0.2) +
  geom_vline(aes(xintercept = mean(zTreatedMatched)),
             color = "coral", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = mean(zControlMatched)),
             color = "steelblue", linetype = "dashed", size = 1) +
  labs(
    title = "Distribution of z: AFTER Matching",
    subtitle = "Dashed lines show group means - much closer now!",
    x = "z (observed confounder)",
    y = "Count",
    fill = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_fill_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pHistAfter)

# Combined faceted histogram
pHistCombined <- ggplot(boxDataCombined, aes(x = z, fill = group)) +
  geom_histogram(alpha = 0.5, position = "identity", bins = 30,
                 color = "white", size = 0.2) +
  facet_wrap(~timing, ncol = 2) +
  labs(
    title = "Histogram Comparison: Before vs After Matching",
    subtitle = "Good balance = histograms overlap almost completely",
    x = "z (observed confounder)",
    y = "Count",
    fill = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_fill_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pHistCombined)


# ------------------------------------------------------------------------------
# 5.8 Visualizing the KS Test: Empirical CDFs
# ------------------------------------------------------------------------------
# The KS test compares Empirical Cumulative Distribution Functions (ECDFs).
# The KS statistic is the MAXIMUM vertical distance between the two ECDFs.
#
# ECDF explained:
#   - For any value x, ECDF(x) = proportion of observations <= x
#   - Starts at 0 (no observations below minimum)
#   - Ends at 1 (all observations below maximum)
#   - Step function that jumps up at each observed value
#
# For good balance: the two ECDF curves should be very close together
# ------------------------------------------------------------------------------

# Create ECDF data - BEFORE matching
ecdfTreatedBefore <- ecdf(obsData$z[obsData$Treat == 1])
ecdfControlBefore <- ecdf(obsData$z[obsData$Treat == 0])

# Create a sequence of z values to evaluate the ECDFs
zSeq <- seq(min(obsData$z) - 0.5, max(obsData$z) + 0.5, length.out = 500)

ecdfDataBefore <- data.frame(
  z = rep(zSeq, 2),
  ecdf = c(ecdfTreatedBefore(zSeq), ecdfControlBefore(zSeq)),
  group = rep(c("Treated", "Control"), each = length(zSeq)),
  timing = "Before Matching"
)

# Create ECDF data - AFTER matching
ecdfTreatedAfter <- ecdf(zTreatedMatched)
ecdfControlAfter <- ecdf(zControlMatched)

ecdfDataAfter <- data.frame(
  z = rep(zSeq, 2),
  ecdf = c(ecdfTreatedAfter(zSeq), ecdfControlAfter(zSeq)),
  group = rep(c("Treated", "Control"), each = length(zSeq)),
  timing = "After Matching"
)

# Combine
ecdfDataCombined <- rbind(ecdfDataBefore, ecdfDataAfter)
ecdfDataCombined$timing <- factor(ecdfDataCombined$timing,
                                   levels = c("Before Matching", "After Matching"))

# Find where the maximum difference occurs (for annotation) - BEFORE
diffBefore <- abs(ecdfTreatedBefore(zSeq) - ecdfControlBefore(zSeq))
maxDiffIdxBefore <- which.max(diffBefore)
maxDiffZBefore <- zSeq[maxDiffIdxBefore]
maxDiffValBefore <- diffBefore[maxDiffIdxBefore]

# ECDF plot - BEFORE matching with KS statistic annotation
pEcdfBefore <- ggplot(subset(ecdfDataCombined, timing == "Before Matching"),
                       aes(x = z, y = ecdf, color = group)) +
  geom_line(size = 1.2) +
  # Add vertical line showing max difference (KS statistic)
  geom_segment(aes(x = maxDiffZBefore, xend = maxDiffZBefore,
                   y = ecdfControlBefore(maxDiffZBefore),
                   yend = ecdfTreatedBefore(maxDiffZBefore)),
               color = "black", size = 1, linetype = "solid",
               arrow = arrow(ends = "both", length = unit(0.1, "inches"))) +
  annotate("text", x = maxDiffZBefore + 0.3, y = (ecdfControlBefore(maxDiffZBefore) +
                                                    ecdfTreatedBefore(maxDiffZBefore))/2,
           label = paste0("KS = ", round(ksBefore$statistic, 3)),
           size = 4, fontface = "bold", hjust = 0) +
  labs(
    title = "Empirical CDFs: BEFORE Matching",
    subtitle = "KS statistic = maximum vertical gap between curves",
    x = "z (observed confounder)",
    y = "Cumulative Probability",
    color = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_color_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pEcdfBefore)

# Find max difference - AFTER
diffAfter <- abs(ecdfTreatedAfter(zSeq) - ecdfControlAfter(zSeq))
maxDiffIdxAfter <- which.max(diffAfter)
maxDiffZAfter <- zSeq[maxDiffIdxAfter]
maxDiffValAfter <- diffAfter[maxDiffIdxAfter]

# ECDF plot - AFTER matching
pEcdfAfter <- ggplot(subset(ecdfDataCombined, timing == "After Matching"),
                      aes(x = z, y = ecdf, color = group)) +
  geom_line(size = 1.2) +
  # Add vertical line showing max difference (KS statistic)
  geom_segment(aes(x = maxDiffZAfter, xend = maxDiffZAfter,
                   y = ecdfControlAfter(maxDiffZAfter),
                   yend = ecdfTreatedAfter(maxDiffZAfter)),
               color = "black", size = 1, linetype = "solid",
               arrow = arrow(ends = "both", length = unit(0.1, "inches"))) +
  annotate("text", x = maxDiffZAfter + 0.3, y = (ecdfControlAfter(maxDiffZAfter) +
                                                   ecdfTreatedAfter(maxDiffZAfter))/2,
           label = paste0("KS = ", round(ksAfter$statistic, 3)),
           size = 4, fontface = "bold", hjust = 0) +
  labs(
    title = "Empirical CDFs: AFTER Matching",
    subtitle = "Notice how much smaller the maximum gap is now!",
    x = "z (observed confounder)",
    y = "Cumulative Probability",
    color = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_color_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pEcdfAfter)

# Side-by-side ECDF comparison
pEcdfCombined <- ggplot(ecdfDataCombined, aes(x = z, y = ecdf, color = group)) +
  geom_line(size = 1) +
  facet_wrap(~timing) +
  labs(
    title = "ECDF Comparison: What the KS Test Measures",
    subtitle = paste0("KS statistic: Before = ", round(ksBefore$statistic, 3),
                     " | After = ", round(ksAfter$statistic, 3)),
    x = "z (observed confounder)",
    y = "Cumulative Probability",
    color = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_color_manual(values = c("Control" = "steelblue", "Treated" = "coral"))

print(pEcdfCombined)

# INTERPRETING ECDF PLOTS:
# ------------------------
# - If distributions are identical, ECDFs would overlap perfectly
# - Horizontal shift = difference in location (means)
# - Different slopes = difference in spread (variances)
# - The KS statistic measures the worst-case vertical gap
# - Smaller KS statistic = better balance
#
# Compare the plots:
# - BEFORE: Large gap between curves, especially in the middle
# - AFTER: Curves are much closer together throughout

cat("\n--- Visual Balance Summary ---\n")
cat("KS Statistic BEFORE matching:", round(ksBefore$statistic, 3), "\n")
cat("KS Statistic AFTER matching: ", round(ksAfter$statistic, 3), "\n")
cat("Improvement:", round((1 - ksAfter$statistic/ksBefore$statistic)*100, 1), "%\n")

# Clean up temporary plotting data
rm(boxDataBefore, boxDataAfter, boxDataCombined)
rm(ecdfTreatedBefore, ecdfControlBefore, ecdfTreatedAfter, ecdfControlAfter)
rm(zSeq, ecdfDataBefore, ecdfDataAfter, ecdfDataCombined)
rm(diffBefore, diffAfter, maxDiffIdxBefore, maxDiffIdxAfter)
rm(maxDiffZBefore, maxDiffZAfter, maxDiffValBefore, maxDiffValAfter)
rm(pBoxPlot, pBoxPlotPoints, pHistBefore, pHistAfter, pHistCombined)
rm(pEcdfBefore, pEcdfAfter, pEcdfCombined)


# ==============================================================================
# PART 6: QQ PLOT HELPER FUNCTION
# ==============================================================================
# QQ (Quantile-Quantile) plots visually compare two distributions.
# They're essential for assessing balance beyond just means.
#
# In a QQ plot:
# - Each point represents a quantile from each distribution
# - If distributions are identical, points fall on the 45-degree line
# - Deviations from the line show where distributions differ
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# 6.1 Create Reusable QQ Balance Plot Function
# ------------------------------------------------------------------------------

createQqBalancePlot <- function(treatedValues, controlValues,
                                 varName = "Variable",
                                 showStats = TRUE) {
  #' Create a QQ plot comparing treated and control distributions
  #'
  #' @param treatedValues Numeric vector of values from treated group
  #' @param controlValues Numeric vector of values from control group
  #' @param varName Character string for variable name (used in title)
  #' @param showStats Logical, whether to print qq statistics
  #'
  #' @return A ggplot object and prints qqstats if showStats = TRUE

  # Calculate qq statistics
  qqResult <- qqstats(treatedValues, controlValues)

  # Sort values for QQ plot
  # We need equal-length vectors for plotting
  nTreat <- length(treatedValues)
  nControl <- length(controlValues)

  # Generate quantiles at same probability points
  probs <- seq(0, 1, length.out = min(nTreat, nControl))

  # Get quantiles from each distribution
  qTreated <- quantile(treatedValues, probs = probs, na.rm = TRUE)
  qControl <- quantile(controlValues, probs = probs, na.rm = TRUE)

  # Create data frame for plotting
  qqData <- data.frame(
    Treated = qTreated,
    Control = qControl
  )

  # Calculate axis limits using quantiles to handle outliers
  # Use 1st and 99th percentiles to avoid extreme outliers stretching the plot
  allValues <- c(treatedValues, controlValues)
  axisMin <- quantile(allValues, 0.01, na.rm = TRUE)
  axisMax <- quantile(allValues, 0.99, na.rm = TRUE)

  # Add a small buffer
  buffer <- (axisMax - axisMin) * 0.05
  axisMin <- axisMin - buffer
  axisMax <- axisMax + buffer

  # Create the plot
  p <- ggplot(qqData, aes(x = Control, y = Treated)) +
    # Add 45-degree reference line FIRST (so points are on top)
    geom_abline(intercept = 0, slope = 1,
                linetype = "dashed", color = "red", size = 1) +
    # Add points
    geom_point(alpha = 0.6, color = "steelblue", size = 2) +
    # Set equal axis limits
    coord_fixed(ratio = 1,
                xlim = c(axisMin, axisMax),
                ylim = c(axisMin, axisMax)) +
    # Labels
    labs(
      title = paste("QQ Plot:", varName),
      subtitle = paste0("Mean diff = ", round(qqResult$meandiff, 3),
                       " | Median diff = ", round(qqResult$mediandiff, 3),
                       " | Max diff = ", round(qqResult$maxdiff, 3)),
      x = "Control Quantiles",
      y = "Treated Quantiles"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold"),
      plot.subtitle = element_text(size = 10, color = "gray40")
    )

  # Print statistics if requested
  if (showStats) {
    cat("\n--- QQ Statistics for", varName, "---\n")
    cat("Mean difference:   ", round(qqResult$meandiff, 4), "\n")
    cat("Median difference: ", round(qqResult$mediandiff, 4), "\n")
    cat("Max difference:    ", round(qqResult$maxdiff, 4), "\n")
    cat("\nINTERPRETATION:\n")
    cat("- Points on the diagonal = perfect balance\n")
    cat("- Points above diagonal = treated quantiles > control quantiles\n")
    cat("- Points below diagonal = treated quantiles < control quantiles\n")
  }

  # Return both plot and stats
  return(list(plot = p, stats = qqResult))
}

# ------------------------------------------------------------------------------
# 6.2 Example Usage of QQ Balance Plot Function
# ------------------------------------------------------------------------------

# Before matching: Compare z between treated and control
cat("\n", rep("=", 60), "\n")
cat("QQ PLOT: BEFORE MATCHING\n")
cat(rep("=", 60), "\n")

qqBefore <- createQqBalancePlot(
  treatedValues = obsData$z[obsData$Treat == 1],
  controlValues = obsData$z[obsData$Treat == 0],
  varName = "z (Before Matching)"
)
print(qqBefore$plot)

# After matching: Compare z between matched treated and control
cat("\n", rep("=", 60), "\n")
cat("QQ PLOT: AFTER PSM MATCHING\n")
cat(rep("=", 60), "\n")

qqAfter <- createQqBalancePlot(
  treatedValues = zTreatedMatched,
  controlValues = zControlMatched,
  varName = "z (After PSM)"
)
print(qqAfter$plot)

# Compare the improvement!
cat("\n--- Balance Improvement Summary ---\n")
cat("Mean QQ diff BEFORE:", round(qqBefore$stats$meandiff, 4), "\n")
cat("Mean QQ diff AFTER: ", round(qqAfter$stats$meandiff, 4), "\n")
cat("Improvement:", round((1 - qqAfter$stats$meandiff/qqBefore$stats$meandiff)*100, 1), "%\n")


# ==============================================================================
# PART 7: GENETIC MATCHING
# ==============================================================================
# Genetic matching uses an evolutionary algorithm to find optimal weights
# for covariates, DIRECTLY minimizing imbalance rather than matching on
# propensity scores.
#
# Key differences from propensity score matching:
# - PSM: Match on P(Treat|X), hope this balances X
# - GenMatch: Directly optimize weights to balance X
#
# GenMatch often achieves better balance because it targets balance directly,
# rather than as a side effect of matching on propensity scores.
# ------------------------------------------------------------------------------

cat("\n", rep("=", 70), "\n")
cat("GENETIC MATCHING\n")
cat(rep("=", 70), "\n")

# ------------------------------------------------------------------------------
# 7.1 Run Genetic Matching
# ------------------------------------------------------------------------------
# GenMatch() finds optimal weights for the matching variables
# It uses a genetic algorithm to minimize balance statistics
# ------------------------------------------------------------------------------

# Prepare covariates matrix (GenMatch requires a matrix)
X <- as.matrix(obsData$z)

# Run genetic matching
# Note: This may print a lot of output as it optimizes
# pop.size = population size for genetic algorithm (higher = better but slower)
# wait.generations = generations without improvement before stopping

genMatch <- GenMatch(
  Tr = obsData$Treat,          # Treatment indicator
  X = X,                        # Covariates to balance
  estimand = "ATT",             # Average Treatment effect on the Treated
  pop.size = 100,               # Population size for genetic algorithm
  wait.generations = 4,         # Patience parameter
  print.level = 1               # How much output to show (0 = quiet)
)

# Now use the genetic weights to perform matching
genResult <- Match(
  Y = obsData$y,
  Tr = obsData$Treat,
  X = X,
  Weight.matrix = genMatch,    # Use the optimized weights!
  estimand = "ATT",
  replace = TRUE
)

summary(genResult)

cat("\n--- Genetic Matching Results ---\n")
cat("Estimated ATT:", round(genResult$est, 3), "\n")
cat("Standard Error:", round(genResult$se, 3), "\n")
cat("Bias (from true effect of 2):", round(genResult$est - 2, 3), "\n")

# ------------------------------------------------------------------------------
# 7.2 Compare Balance: PSM vs Genetic Matching
# ------------------------------------------------------------------------------

cat("\n", rep("=", 70), "\n")
cat("BALANCE COMPARISON: PSM vs GENETIC MATCHING\n")
cat(rep("=", 70), "\n")

# Balance after genetic matching
cat("\n--- Balance After Genetic Matching ---\n")
balanceGen <- MatchBalance(
  Treat ~ z,
  data = obsData,
  match.out = genResult,
  nboots = 500
)

# Get matched values for genetic matching
zTreatedGen <- obsData$z[genResult$index.treated]
zControlGen <- obsData$z[genResult$index.control]

# QQ plot for genetic matching
qqGen <- createQqBalancePlot(
  treatedValues = zTreatedGen,
  controlValues = zControlGen,
  varName = "z (After Genetic Matching)"
)
print(qqGen$plot)

# Compare balance statistics
cat("\n--- Balance Comparison Summary ---\n")
cat("Method          | Mean QQ Diff | Max QQ Diff\n")
cat("-------------------------------------------------\n")
cat(sprintf("Before Matching | %12.4f | %11.4f\n",
            qqBefore$stats$meandiff, qqBefore$stats$maxdiff))
cat(sprintf("PSM             | %12.4f | %11.4f\n",
            qqAfter$stats$meandiff, qqAfter$stats$maxdiff))
cat(sprintf("Genetic Match   | %12.4f | %11.4f\n",
            qqGen$stats$meandiff, qqGen$stats$maxdiff))


# ==============================================================================
# PART 8: MODEL DEPENDENCE DEMONSTRATION
# ==============================================================================
# A key benefit of matching: reduced MODEL DEPENDENCE
#
# Without matching, estimates can change dramatically depending on:
# - Which functional form we use (linear, quadratic, etc.)
# - Which interactions we include
# - How we specify the model
#
# After good matching, treated and control groups are similar, so the
# regression doesn't need to "extrapolate" as much. This makes estimates
# more stable across different specifications.
#
# This demonstrates a key point from the textbook: matching reduces the
# sensitivity of results to modeling assumptions.
# ------------------------------------------------------------------------------

cat("\n", rep("=", 70), "\n")
cat("MODEL DEPENDENCE DEMONSTRATION\n")
cat(rep("=", 70), "\n")

# ------------------------------------------------------------------------------
# 8.1 Different Model Specifications on UNMATCHED Data
# ------------------------------------------------------------------------------

cat("\n--- Unmatched Data: Different Specifications ---\n")

# Model 1: Simple linear
m1Unmatched <- lm(y ~ Treat, data = obsData)

# Model 2: Linear control for z
m2Unmatched <- lm(y ~ Treat + z, data = obsData)

# Model 3: Quadratic in z
m3Unmatched <- lm(y ~ Treat + z + I(z^2), data = obsData)

# Model 4: Cubic in z
m4Unmatched <- lm(y ~ Treat + z + I(z^2) + I(z^3), data = obsData)

# Model 5: With interaction
m5Unmatched <- lm(y ~ Treat * z, data = obsData)

# Model 6: Complex specification
m6Unmatched <- lm(y ~ Treat * z + I(z^2), data = obsData)

# Collect estimates
unmatchedEstimates <- c(
  "No controls" = coef(m1Unmatched)["Treat"],
  "Linear z" = coef(m2Unmatched)["Treat"],
  "Quadratic z" = coef(m3Unmatched)["Treat"],
  "Cubic z" = coef(m4Unmatched)["Treat"],
  "z interaction" = coef(m5Unmatched)["Treat"],
  "Complex" = coef(m6Unmatched)["Treat"]
)

cat("\nEstimates from different specifications:\n")
print(round(unmatchedEstimates, 3))
cat("\nRange of estimates:", round(max(unmatchedEstimates) - min(unmatchedEstimates), 3), "\n")
cat("(True effect is 2)\n")

# ------------------------------------------------------------------------------
# 8.2 Different Model Specifications on MATCHED Data (PSM)
# ------------------------------------------------------------------------------

cat("\n--- PSM Matched Data: Different Specifications ---\n")

# Create matched dataset for regression
# For PSM, we use the matched pairs

matchedPsmData <- data.frame(
  yTreat = obsData$y[psmResult$index.treated],
  yControl = obsData$y[psmResult$index.control],
  zTreat = obsData$z[psmResult$index.treated],
  zControl = obsData$z[psmResult$index.control],
  Treat = c(rep(1, length(psmResult$index.treated)),
            rep(0, length(psmResult$index.control))),
  y = c(obsData$y[psmResult$index.treated],
        obsData$y[psmResult$index.control]),
  z = c(obsData$z[psmResult$index.treated],
        obsData$z[psmResult$index.control])
)

# Model specifications on matched data
m1Psm <- lm(y ~ Treat, data = matchedPsmData)
m2Psm <- lm(y ~ Treat + z, data = matchedPsmData)
m3Psm <- lm(y ~ Treat + z + I(z^2), data = matchedPsmData)
m4Psm <- lm(y ~ Treat + z + I(z^2) + I(z^3), data = matchedPsmData)
m5Psm <- lm(y ~ Treat * z, data = matchedPsmData)
m6Psm <- lm(y ~ Treat * z + I(z^2), data = matchedPsmData)

# Collect estimates
psmEstimates <- c(
  "No controls" = coef(m1Psm)["Treat"],
  "Linear z" = coef(m2Psm)["Treat"],
  "Quadratic z" = coef(m3Psm)["Treat"],
  "Cubic z" = coef(m4Psm)["Treat"],
  "z interaction" = coef(m5Psm)["Treat"],
  "Complex" = coef(m6Psm)["Treat"]
)

cat("\nEstimates from different specifications:\n")
print(round(psmEstimates, 3))
cat("\nRange of estimates:", round(max(psmEstimates) - min(psmEstimates), 3), "\n")
cat("(True effect is 2)\n")

# ------------------------------------------------------------------------------
# 8.3 Different Model Specifications on MATCHED Data (Genetic)
# ------------------------------------------------------------------------------

cat("\n--- Genetic Matched Data: Different Specifications ---\n")

matchedGenData <- data.frame(
  Treat = c(rep(1, length(genResult$index.treated)),
            rep(0, length(genResult$index.control))),
  y = c(obsData$y[genResult$index.treated],
        obsData$y[genResult$index.control]),
  z = c(obsData$z[genResult$index.treated],
        obsData$z[genResult$index.control])
)

m1Gen <- lm(y ~ Treat, data = matchedGenData)
m2Gen <- lm(y ~ Treat + z, data = matchedGenData)
m3Gen <- lm(y ~ Treat + z + I(z^2), data = matchedGenData)
m4Gen <- lm(y ~ Treat + z + I(z^2) + I(z^3), data = matchedGenData)
m5Gen <- lm(y ~ Treat * z, data = matchedGenData)
m6Gen <- lm(y ~ Treat * z + I(z^2), data = matchedGenData)

genEstimates <- c(
  "No controls" = coef(m1Gen)["Treat"],
  "Linear z" = coef(m2Gen)["Treat"],
  "Quadratic z" = coef(m3Gen)["Treat"],
  "Cubic z" = coef(m4Gen)["Treat"],
  "z interaction" = coef(m5Gen)["Treat"],
  "Complex" = coef(m6Gen)["Treat"]
)

cat("\nEstimates from different specifications:\n")
print(round(genEstimates, 3))
cat("\nRange of estimates:", round(max(genEstimates) - min(genEstimates), 3), "\n")
cat("(True effect is 2)\n")

# ------------------------------------------------------------------------------
# 8.4 Visualize Model Dependence
# ------------------------------------------------------------------------------

# Create comparison data frame
modelDepData <- data.frame(
  Specification = factor(rep(names(unmatchedEstimates), 3),
                         levels = names(unmatchedEstimates)),
  Estimate = c(unmatchedEstimates, psmEstimates, genEstimates),
  Data = rep(c("Unmatched", "PSM Matched", "Genetic Matched"), each = 6)
)

# Plot
ggplot(modelDepData, aes(x = Specification, y = Estimate,
                          color = Data, group = Data)) +
  geom_point(size = 3) +
  geom_line(size = 1, alpha = 0.7) +
  geom_hline(yintercept = 2, linetype = "dashed", color = "black", size = 1) +
  annotate("text", x = 6.4, y = 2, label = "True Effect = 2",
           hjust = 0, vjust = -0.5, size = 3) +
  labs(
    title = "Model Dependence: Effect Estimates Across Specifications",
    subtitle = "Good matching reduces sensitivity to model specification",
    x = "Model Specification",
    y = "Estimated Treatment Effect",
    color = "Data"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  ) +
  scale_color_manual(values = c("Unmatched" = "red",
                                "PSM Matched" = "blue",
                                "Genetic Matched" = "darkgreen"))


# ==============================================================================
# PART 9: COMPARISON SUMMARY
# ==============================================================================
# Let's bring it all together: How do all our methods compare?
# ------------------------------------------------------------------------------

cat("\n", rep("=", 70), "\n")
cat("FINAL COMPARISON SUMMARY\n")
cat(rep("=", 70), "\n")

# ------------------------------------------------------------------------------
# 9.1 Summary Table
# ------------------------------------------------------------------------------

# Collect all estimates
summaryTable <- data.frame(
  Method = c(
    "1. Naive (no controls)",
    "2. OLS controlling for z",
    "3. OLS controlling for z + w (oracle)",
    "4. Coarsened Exact Matching",
    "5. Propensity Score Matching",
    "6. Genetic Matching",
    "7. Experimental Benchmark"
  ),
  Estimate = c(
    coef(naiveModel)["Treat"],
    coef(controlledModel)["Treat"],
    coef(fullModel)["Treat"],
    coef(cemModel)["Treat"],
    psmResult$est,
    genResult$est,
    coef(expModel)["Treat"]
  ),
  SE = c(
    summary(naiveModel)$coefficients["Treat", "Std. Error"],
    summary(controlledModel)$coefficients["Treat", "Std. Error"],
    summary(fullModel)$coefficients["Treat", "Std. Error"],
    summary(cemModel)$coefficients["Treat", "Std. Error"],
    psmResult$se,
    genResult$se,
    summary(expModel)$coefficients["Treat", "Std. Error"]
  )
)

summaryTable$Bias <- summaryTable$Estimate - 2
summaryTable$`|Bias|` <- abs(summaryTable$Bias)

cat("\n")
print(summaryTable, digits = 3, row.names = FALSE)

cat("\n")
cat("Notes:\n")
cat("- True causal effect = 2\n")
cat("- Method 3 (oracle) uses unobserved w - not realistic in practice\n")
cat("- All matching methods can only adjust for OBSERVED confounders (z)\n")
cat("- Remaining bias is due to unobserved confounder (w)\n")

# ------------------------------------------------------------------------------
# 9.2 Summary Visualization
# ------------------------------------------------------------------------------

summaryPlotData <- summaryTable
summaryPlotData$Method <- factor(summaryPlotData$Method,
                                  levels = rev(summaryTable$Method))

ggplot(summaryPlotData, aes(x = Estimate, y = Method)) +
  geom_vline(xintercept = 2, linetype = "dashed", color = "darkgreen", size = 1) +
  geom_errorbarh(aes(xmin = Estimate - 1.96*SE, xmax = Estimate + 1.96*SE),
                 height = 0.2, color = "gray40") +
  geom_point(size = 4, color = "steelblue") +
  annotate("text", x = 2, y = 0.3, label = "True Effect",
           color = "darkgreen", size = 3, fontface = "bold") +
  labs(
    title = "Comparison of Treatment Effect Estimates",
    subtitle = "Points show estimates, bars show 95% confidence intervals",
    x = "Estimated Treatment Effect",
    y = ""
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10)
  )


# ==============================================================================
# KEY TAKEAWAYS
# ==============================================================================
#
# 1. MATCHING vs RANDOMIZATION:
#    - Randomization solves confounding by design (treatment independent of confounders)
#    - Matching tries to recreate this by finding similar treated/control units
#    - Matching can only address OBSERVED confounders
#
# 2. THE FUNDAMENTAL LIMITATION:
#    - In our simulation, unobserved w causes bias that no matching method can fix
#    - This is why experiments are preferred when possible
#    - Sensitivity analysis can assess how robust results are to unobserved confounding
#
# 3. BALANCE IS KING:
#    - Always check balance after matching (SMD, QQ plots, KS tests)
#    - SMD < 0.1 is a common threshold for "good" balance
#    - Poor balance = unreliable estimates
#
# 4. GENETIC MATCHING ADVANTAGES:
#    - Directly optimizes balance rather than matching on propensity scores
#    - Often achieves better balance than PSM
#    - More computationally intensive
#
# 5. MODEL DEPENDENCE:
#    - Unmatched data: estimates sensitive to specification choices
#    - Matched data: estimates more stable across specifications
#    - This is a key benefit of matching over regression adjustment alone
#
# 6. PRACTICAL ADVICE:
#    - Check balance thoroughly before trusting matched estimates
#    - Try multiple matching methods and compare
#    - Report balance statistics alongside treatment effect estimates
#    - Be honest about potential for unobserved confounding
#
# ==============================================================================
