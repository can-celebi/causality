# ==============================================================================
# PROPENSITY SCORE MATCHING FROM SCRATCH
# ==============================================================================
# This tutorial implements propensity score matching manually to understand
# exactly what happens at each step. We'll use explicit for loops instead of
# package functions to make the process transparent.
#
# Learning objectives:
# 1. Understand why logistic regression is used for propensity scores
# 2. Calculate propensity scores manually using the sigmoid function
# 3. Implement nearest-neighbor matching with a for loop
# 4. Assess balance improvement after matching
# 5. Estimate treatment effects before and after matching
# 6. Understand when matching outperforms regression adjustment
# ==============================================================================

library(ggplot2)

# ==============================================================================
# THE STORY: Does Using AI Assistants Boost Your Starting Salary?
# ==============================================================================
#
# CONTEXT:
# It's 2026, and public policy master's students are debating whether using AI
# assistants (for writing policy briefs, analyzing data, summarizing research)
# actually helps their career outcomes. Some say it boosts productivity; others
# worry it creates dependency and hurts deep learning.
#
# THE QUESTION:
# Does regularly using AI assistants during your master's program CAUSE higher
# starting salaries at your first policy job?
#
# THE CHALLENGE:
# Students who adopt AI tools might already be different in ways that affect
# both their tool adoption AND their job outcomes. This is CONFOUNDING.
#
# VARIABLES:
#
# Treatment:
#   - ai_user: Regularly used AI assistant during studies (1=yes, 0=no)
#
# Outcome:
#   - salary: Starting salary at first policy job (in $1,000s)
#
# Observed Confounders (we can measure and control for these):
#   - prior_exp: Years of work experience before master's
#   - quant_skills: Quantitative/stats ability (standardized test score)
#   - stem_background: STEM affinity score based on undergrad (noisy measure)
#
# Unobserved Confounders (exist but we can't measure):
#   - curiosity: Intellectual curiosity (Need for Cognition scale)
#   - tech_readiness: Comfort with technology (Lam et al., 2008 scale)
#   - ai_aversion: Skepticism/fear of AI (Schepman & Rodway, 2020 scale)
#
# TRUE CAUSAL EFFECT: Using AI adds $2,000 to starting salary
#
# ==============================================================================

# ==============================================================================
# PART 0: SETUP
# ==============================================================================

set.seed(123)
n <- 900
trueEffect <- 2  # True causal effect: $2,000

cat("\n")
cat("==============================================================================\n")
cat("PROPENSITY SCORE MATCHING FROM SCRATCH\n")
cat("==============================================================================\n")
cat("\nResearch Question: Does using AI assistants during your master's program\n")
cat("                   cause higher starting salaries?\n")
cat("\nSample size:", n, "public policy master's students\n")
cat("True causal effect: $", trueEffect * 1000, " (we know this because it's simulated)\n", sep = "")

# ==============================================================================
# PART 1: DATA GENERATION (IMBALANCED OBSERVATIONAL DATA)
# ==============================================================================
# We create data where AI adoption is confounded - certain characteristics make
# students both more likely to use AI AND more likely to get higher salaries.
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 1: GENERATING OBSERVATIONAL DATA (WITH CONFOUNDING)\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 1.1 Generate OBSERVED confounders (we can measure these)
# ------------------------------------------------------------------------------

cat("\nGenerating observed confounders...\n")

# Prior work experience (0-8 years, most students have 1-3)
prior_exp <- rnorm(n, mean = 2, sd = 1.5)
# we make sure that negative prior work experience becomes 0 to make sense
prior_exp <- ifelse(prior_exp < 0, 0, prior_exp)

# Quantitative skills (standardized, mean=0, sd=1)
quant_skills <- rnorm(n, mean = 0, sd = 1)

# STEM background - noisy measure
# True STEM affinity is latent; we only observe a noisy version
stem_true <- rnorm(n, mean = 0, sd = 1)  # Latent true STEM affinity
stem_background <- stem_true + rnorm(n, mean = 0, sd = 0.5)  # Add measurement noise

cat("  - prior_exp: Years of work experience (mean =", round(mean(prior_exp), 2), ")\n")
cat("  - quant_skills: Quantitative ability, standardized (mean =", round(mean(quant_skills), 2), ")\n")
cat("  - stem_background: STEM affinity, noisy measure (mean =", round(mean(stem_background), 2), ")\n")

# ------------------------------------------------------------------------------
# 1.2 Generate UNOBSERVED confounders (we can't measure these in real life)
# ------------------------------------------------------------------------------

cat("\nGenerating unobserved confounders (we pretend we can't see these)...\n")

# Intellectual curiosity (Need for Cognition scale, standardized)
curiosity <- rnorm(n, mean = 0, sd = 1)

# Technology readiness (Lam et al., 2008 - innovativeness + optimism)
tech_readiness <- rnorm(n, mean = 0, sd = 1)

# AI aversion (Schepman & Rodway, 2020 - negative attitudes toward AI)
# Higher = more skeptical/fearful of AI
ai_aversion <- rnorm(n, mean = 0, sd = 1)

cat("  - curiosity: Intellectual curiosity\n")
cat("  - tech_readiness: Comfort with new technology\n")
cat("  - ai_aversion: Skepticism/fear of AI tools\n")

# ------------------------------------------------------------------------------
# 1.3 Treatment assignment (WHO USES AI?)
# ------------------------------------------------------------------------------
# Students with certain characteristics are more likely to adopt AI tools.
# Note: ai_aversion has NEGATIVE coefficient (averse students AVOID AI)

cat("\nGenerating treatment (AI adoption)...\n")
cat("  Treatment model: logit(P(AI user)) = f(prior_exp, quant_skills, stem_background,\n")
cat("                                         curiosity, tech_readiness, -ai_aversion)\n")

treatLatent <- 0.3 * prior_exp +
               0.5 * quant_skills +
               0.8 * stem_background +
               0.4 * curiosity +
               0.7 * tech_readiness +
               (-0.6) * ai_aversion +  # NEGATIVE: averse students avoid AI
               rnorm(n, 0, 1)

# Use quantile threshold to get approximately 35% treated
# This way we ensure imbalance between treated and not treated
# quantile returns the cut off point for the bottom 65%
threshold <- quantile(treatLatent, 0.65)
threshold
# -- What is quantile --
summary(treatLatent)
quantile(treatLatent, 0.75)
# -----------------------
ai_user <- ifelse(treatLatent > threshold, 1, 0)

cat("\nAI adoption:\n")
cat("  AI users:", sum(ai_user), "(", round(mean(ai_user) * 100, 1), "%)\n")
cat("  Non-users:", sum(ai_user == 0), "(", round(mean(ai_user == 0) * 100, 1), "%)\n")

# ------------------------------------------------------------------------------
# 1.4 Outcome generation (SALARY) - WITH NON-LINEARITY
# ------------------------------------------------------------------------------
# Salary depends on treatment AND confounders.
# Key: We add NON-LINEAR effects so that regression adjustment won't work as well!

cat("\nGenerating outcome (starting salary in $1,000s)...\n")
cat("  Outcome model includes NON-LINEAR terms (quadratic, interaction)\n")

# Base salary around $45,000 for policy jobs
base_salary <- 45

salary <- base_salary +
  
          # treatment effect
          trueEffect * ai_user +              # TRUE CAUSAL EFFECT = $2,000 (i.e. 2)
  
          # observed variables   
          1.0 * prior_exp +                   # Experience helps
          0.8 * prior_exp^2 +                 # NON-LINEAR: strong quadratic effect
          1.5 * quant_skills +                # Quant skills valued
          1.0 * stem_background +             # STEM background helps
          1.5 * quant_skills * stem_background + # STRONG INTERACTION effect
  
          # unobserved variables      
          1.2 * curiosity +                   # Curious people do better
          0.8 * tech_readiness +              # Tech-ready valued in 2026
          (-0.5) * ai_aversion +              # AI-averse seen as less adaptable
  
          # noise
          rnorm(n, 0, 2)                      # Random noise

cat("  True causal effect of AI use: $", trueEffect * 1000, "\n", sep = "")
cat("  Average salary: $", round(mean(salary) * 1000), "\n", sep = "")

# ------------------------------------------------------------------------------
# 1.5 Create data frame
# ------------------------------------------------------------------------------

df <- data.frame(
  id = 1:n,
  ai_user = ai_user,
  prior_exp = prior_exp,
  quant_skills = quant_skills,
  stem_background = stem_background,
  curiosity = curiosity,
  tech_readiness = tech_readiness,
  ai_aversion = ai_aversion,
  salary = salary
)

# ------------------------------------------------------------------------------
# 1.6 Verify imbalance with t-tests and SMD
# ------------------------------------------------------------------------------
# NOTE: For detailed explanation of standardization and SMD concepts,
# see the companion file: standardization_concepts.R

cat("\n------------------------------------------------------------------------------\n")
cat("COVARIATE BALANCE CHECK (Before Matching)\n")
cat("------------------------------------------------------------------------------\n")

# SMD = Standardized Mean Difference
# Formula: SMD = (Mean_treated - Mean_control) / Pooled_SD
# Interpretation: |SMD| < 0.1 is good balance, > 0.25 is poor balance

calcSMD <- function(x, treat) {
  
  meanT <- mean(x[treat == 1])
  meanC <- mean(x[treat == 0])
  
  sdT <- sd(x[treat == 1])
  sdC <- sd(x[treat == 0])
  
  pooledSD <- sqrt((sdT^2 + sdC^2) / 2)
  
  smd <- (meanT - meanC) / pooledSD
  
  return(smd)
  
}

# Calculate SMD for observed confounders
smd1 <- calcSMD(prior_exp, ai_user)
smd2 <- calcSMD(quant_skills, ai_user)
smd3 <- calcSMD(stem_background, ai_user)

# Perform t-tests for observed confounders
ttest1 <- t.test(prior_exp[ai_user == 1], prior_exp[ai_user == 0])
ttest2 <- t.test(quant_skills[ai_user == 1], quant_skills[ai_user == 0])
ttest3 <- t.test(stem_background[ai_user == 1], stem_background[ai_user == 0])

# Create balance table for OBSERVED confounders
balance_observed <- data.frame(
  Variable = c("prior_exp", "quant_skills", "stem_background"),
  Mean_AI = round(c(mean(prior_exp[ai_user == 1]),
                    mean(quant_skills[ai_user == 1]),
                    mean(stem_background[ai_user == 1])), 2),
  Mean_No = round(c(mean(prior_exp[ai_user == 0]),
                    mean(quant_skills[ai_user == 0]),
                    mean(stem_background[ai_user == 0])), 2),
  SMD = round(c(smd1, smd2, smd3), 3),
  t_test_p = format(c(ttest1$p.value, ttest2$p.value, ttest3$p.value),
                    scientific = TRUE, digits = 2),
  Balance = ifelse(abs(c(smd1, smd2, smd3)) < 0.1, "Good",
                   ifelse(abs(c(smd1, smd2, smd3)) < 0.25, "OK", "Poor"))
)

cat("\nOBSERVED Confounders (we can control for these):\n")
print(balance_observed, row.names = FALSE)
cat("\nNote: t-test p-values show if groups are statistically different (p < 0.05 = significant)\n")

# Interpretation: |SMD| < 0.1 is good, < 0.25 is OK, > 0.25 is poor
# AI users have MORE experience, HIGHER quant skills, MORE STEM background
# These differences create CONFOUNDING!



# ------------------------------------------------------------------------------
# 1.7 Visualize imbalance
# ------------------------------------------------------------------------------

plotData <- data.frame(
  value = c(prior_exp, quant_skills, stem_background),
  variable = rep(c("prior_exp", "quant_skills", "stem_background"), each = n),
  group = factor(rep(ai_user, 3), labels = c("Non-user", "AI User"))
)

p1 <- ggplot(plotData, aes(x = group, y = value, fill = group)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ variable, scales = "free_y") +
  scale_fill_manual(values = c("Non-user" = "steelblue", "AI User" = "coral")) +
  labs(title = "Covariate Imbalance Before Matching",
       subtitle = "AI users differ systematically from non-users (confounding!)",
       x = "Group", y = "Value") +
  theme_minimal() +
  theme(legend.position = "none")

print(p1)

# ------------------------------------------------------------------------------
# 1.8 Visualize imbalance in UNOBSERVED confounders
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("1.8 Imbalance in UNOBSERVED Confounders (we can peek since it's simulated!)\n")
cat("------------------------------------------------------------------------------\n")

smd_cur <- calcSMD(curiosity, ai_user)
smd_tech <- calcSMD(tech_readiness, ai_user)
smd_aver <- calcSMD(ai_aversion, ai_user)

# Perform t-tests for unobserved confounders
ttest_cur <- t.test(curiosity[ai_user == 1], curiosity[ai_user == 0])
ttest_tech <- t.test(tech_readiness[ai_user == 1], tech_readiness[ai_user == 0])
ttest_aver <- t.test(ai_aversion[ai_user == 1], ai_aversion[ai_user == 0])

# Create balance table for UNOBSERVED confounders
balance_unobserved <- data.frame(
  Variable = c("curiosity", "tech_readiness", "ai_aversion"),
  Mean_AI = round(c(mean(curiosity[ai_user == 1]),
                    mean(tech_readiness[ai_user == 1]),
                    mean(ai_aversion[ai_user == 1])), 2),
  Mean_No = round(c(mean(curiosity[ai_user == 0]),
                    mean(tech_readiness[ai_user == 0]),
                    mean(ai_aversion[ai_user == 0])), 2),
  SMD = round(c(smd_cur, smd_tech, smd_aver), 3),
  t_test_p = format(c(ttest_cur$p.value, ttest_tech$p.value, ttest_aver$p.value),
                    scientific = TRUE, digits = 2),
  Balance = ifelse(abs(c(smd_cur, smd_tech, smd_aver)) < 0.1, "Good",
                   ifelse(abs(c(smd_cur, smd_tech, smd_aver)) < 0.25, "OK", "Poor"))
)

cat("\nUNOBSERVED Confounders (in real life, we couldn't see this!):\n")
print(balance_unobserved, row.names = FALSE)

cat("\nNote: ai_aversion has NEGATIVE SMD because AI-averse students AVOID using AI!\n")

plotDataUnobs <- data.frame(
  value = c(curiosity, tech_readiness, ai_aversion),
  variable = rep(c("curiosity", "tech_readiness", "ai_aversion"), each = n),
  group = factor(rep(ai_user, 3), labels = c("Non-user", "AI User"))
)

p1b <- ggplot(plotDataUnobs, aes(x = group, y = value, fill = group)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ variable, scales = "free_y") +
  scale_fill_manual(values = c("Non-user" = "steelblue", "AI User" = "coral")) +
  labs(title = "UNOBSERVED Confounder Imbalance (We Can't Control for These!)",
       subtitle = "In real life, we wouldn't know about this imbalance",
       x = "Group", y = "Value") +
  theme_minimal() +
  theme(legend.position = "none")

print(p1b)

cat("\nKEY INSIGHT: Even if we match perfectly on observed confounders,\n")
cat("             these unobserved differences will still cause bias!\n")

# ------------------------------------------------------------------------------
# 1.9 Density overlap plots for each variable
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("1.9 Distribution Overlap: How Different Are the Groups?\n")
cat("------------------------------------------------------------------------------\n")

cat("\nDensity plots show HOW MUCH the distributions overlap.\n")
cat("Less overlap = more imbalance = more confounding potential.\n")

# Create density plots for OBSERVED confounders
p1c_prior <- ggplot(df, aes(x = prior_exp, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "Prior Experience: Distribution by Group",
       subtitle = paste0("SMD = ", round(calcSMD(prior_exp, ai_user), 2)),
       x = "Years of Experience", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

p1c_quant <- ggplot(df, aes(x = quant_skills, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "Quantitative Skills: Distribution by Group",
       subtitle = paste0("SMD = ", round(calcSMD(quant_skills, ai_user), 2)),
       x = "Quant Skills (standardized)", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

p1c_stem <- ggplot(df, aes(x = stem_background, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "STEM Background: Distribution by Group",
       subtitle = paste0("SMD = ", round(calcSMD(stem_background, ai_user), 2)),
       x = "STEM Affinity Score", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p1c_prior)
print(p1c_quant)
print(p1c_stem)

cat("\nOBSERVED confounders show clear separation - AI users differ from non-users.\n")

# Create density plots for UNOBSERVED confounders
p1d_curiosity <- ggplot(df, aes(x = curiosity, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "Curiosity (UNOBSERVED): Distribution by Group",
       subtitle = paste0("SMD = ", round(calcSMD(curiosity, ai_user), 2)),
       x = "Intellectual Curiosity", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

p1d_tech <- ggplot(df, aes(x = tech_readiness, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "Tech Readiness (UNOBSERVED): Distribution by Group",
       subtitle = paste0("SMD = ", round(calcSMD(tech_readiness, ai_user), 2)),
       x = "Technology Readiness", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

p1d_aversion <- ggplot(df, aes(x = ai_aversion, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "AI Aversion (UNOBSERVED): Distribution by Group",
       subtitle = paste0("SMD = ", round(calcSMD(ai_aversion, ai_user), 2), " (negative = AI users are LESS averse)"),
       x = "AI Aversion Score", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p1d_curiosity)
print(p1d_tech)
print(p1d_aversion)

cat("\nUNOBSERVED confounders also show imbalance - but we can't control for these!\n")

# ==============================================================================
# PART 2: LOGISTIC REGRESSION TUTORIAL
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 2: LOGISTIC REGRESSION TUTORIAL\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 2.1 Why linear regression fails for binary outcomes
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.1 Why Linear Regression Fails for Binary Outcomes\n")
cat("------------------------------------------------------------------------------\n")

linearModel <- lm(ai_user ~ stem_background, data = df)

predData <- data.frame(stem_background = seq(min(stem_background) - 1, max(stem_background) + 1, length.out = 200))
predData$linearPred <- predict(linearModel, newdata = predData)

p2 <- ggplot() +
  geom_point(data = df, aes(x = stem_background, y = ai_user),
             alpha = 0.3, color = "gray40") +
  geom_line(data = predData, aes(x = stem_background, y = linearPred),
            color = "red", linewidth = 1.2) +
  geom_hline(yintercept = c(0, 1), linetype = "dashed", color = "blue") +
  labs(title = "Problem: Linear Regression Predicts Outside [0, 1]",
       subtitle = "We need probabilities, not unbounded predictions",
       x = "STEM Background", y = "P(AI User)") +
  theme_minimal() +
  ylim(-0.3, 1.3)

print(p2)

cat("\nLinear regression can predict values < 0 or > 1.\n")
cat("This doesn't make sense for probabilities!\n")

# ------------------------------------------------------------------------------
# 2.2 The sigmoid function
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.2 The Sigmoid Function\n")
cat("------------------------------------------------------------------------------\n")

sigmoid <- function(z) {
  1 / (1 + exp(-z))
}

cat("\nThe sigmoid function: sigmoid(z) = 1 / (1 + exp(-z))\n")
cat("\nKey properties:\n")
cat("  - Output always between 0 and 1\n")
cat("  - sigmoid(0) = 0.5\n")
cat("  - As z → +∞, sigmoid(z) → 1\n")
cat("  - As z → -∞, sigmoid(z) → 0\n")

# Plot sigmoid
zValues <- seq(-6, 6, length.out = 200)
sigmoidData <- data.frame(z = zValues, probability = sigmoid(zValues))

p3 <- ggplot(sigmoidData, aes(x = z, y = probability)) +
  geom_line(color = "darkgreen", linewidth = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red", alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", alpha = 0.7) +
  labs(title = "The Sigmoid (Logistic) Function",
       subtitle = "Maps any real number to probability between 0 and 1",
       x = "z (linear combination)", y = "Probability") +
  theme_minimal()

print(p3)

# ------------------------------------------------------------------------------
# 2.3 How the intercept affects the curve
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.3 How the Intercept (β₀) Affects the Curve\n")
cat("------------------------------------------------------------------------------\n")

cat("\nThe intercept shifts the curve LEFT or RIGHT:\n")
cat("  - Larger β₀ → curve shifts LEFT (higher probabilities for same x)\n")
cat("  - Smaller β₀ → curve shifts RIGHT (lower probabilities for same x)\n")

interceptData <- data.frame(
  z = rep(zValues, 3),
  probability = c(sigmoid(zValues - 2), sigmoid(zValues), sigmoid(zValues + 2)),
  intercept = factor(rep(c("β₀ = -2 (shifted right)", "β₀ = 0 (baseline)", "β₀ = +2 (shifted left)"), each = 200),
                     levels = c("β₀ = -2 (shifted right)", "β₀ = 0 (baseline)", "β₀ = +2 (shifted left)"))
)

p3b <- ggplot(interceptData, aes(x = z, y = probability, color = intercept)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.5) +
  scale_color_manual(values = c("coral", "gray40", "steelblue")) +
  labs(title = "How Intercept Shifts the Sigmoid Curve",
       subtitle = "Larger intercept = higher probability at any given x value",
       x = "x (predictor)", y = "Probability",
       color = "Intercept") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p3b)

# ------------------------------------------------------------------------------
# 2.4 How the slope affects the curve
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.4 How the Slope (β₁) Affects the Curve\n")
cat("------------------------------------------------------------------------------\n")

cat("\nThe slope changes how STEEP the curve is:\n")
cat("  - Larger |β₁| → steeper curve (sharper transition)\n")
cat("  - Smaller |β₁| → flatter curve (more gradual transition)\n")

slopeData <- data.frame(
  z = rep(zValues, 3),
  probability = c(sigmoid(0.5 * zValues), sigmoid(zValues), sigmoid(2 * zValues)),
  slope = factor(rep(c("β₁ = 0.5 (gradual)", "β₁ = 1.0 (baseline)", "β₁ = 2.0 (steep)"), each = 200),
                 levels = c("β₁ = 0.5 (gradual)", "β₁ = 1.0 (baseline)", "β₁ = 2.0 (steep)"))
)

p3c <- ggplot(slopeData, aes(x = z, y = probability, color = slope)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", alpha = 0.5) +
  scale_color_manual(values = c("coral", "gray40", "steelblue")) +
  labs(title = "How Slope Changes the Steepness",
       subtitle = "Larger slope = sharper transition from 0 to 1",
       x = "x (predictor)", y = "Probability",
       color = "Slope") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p3c)

# ------------------------------------------------------------------------------
# 2.5 Logistic regression: Fitting the sigmoid to binary data
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.5 Logistic Regression: Fitting the Sigmoid to Binary Data\n")
cat("------------------------------------------------------------------------------\n")

cat("\nLogistic regression finds the best sigmoid curve to predict binary outcomes.\n")
cat("Compare to linear regression: the sigmoid stays within [0, 1]!\n")

# Fit logistic regression for visualization
logitModel <- glm(ai_user ~ stem_background, data = df, family = binomial)

# Create prediction data
predDataLogit <- data.frame(stem_background = seq(min(stem_background) - 1, max(stem_background) + 1, length.out = 200))
predDataLogit$logitPred <- predict(logitModel, newdata = predDataLogit, type = "response")
predDataLogit$linearPred <- predict(linearModel, newdata = predDataLogit)

p3d <- ggplot() +
  geom_point(data = df, aes(x = stem_background, y = ai_user),
             alpha = 0.2, color = "gray40") +
  geom_line(data = predDataLogit, aes(x = stem_background, y = linearPred, color = "Linear"),
            linewidth = 1.2, linetype = "dashed") +
  geom_line(data = predDataLogit, aes(x = stem_background, y = logitPred, color = "Logistic"),
            linewidth = 1.2) +
  geom_hline(yintercept = c(0, 1), linetype = "dotted", color = "gray50") +
  scale_color_manual(values = c("Linear" = "coral", "Logistic" = "darkgreen"),
                     name = "Model") +
  labs(title = "Logistic vs Linear Regression for Binary Outcomes",
       subtitle = "Logistic (green) shows S-curve, linear (red dashed) goes outside [0,1]",
       x = "STEM Background", y = "P(AI User)") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  ylim(-0.2, 1.2)

print(p3d)

cat("\nThe logistic curve (green) fits the binary data properly!\n")
cat("It gives us valid probabilities between 0 and 1.\n")

# ==============================================================================
# PART 3: MANUAL PROPENSITY SCORE CALCULATION
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 3: MANUAL PROPENSITY SCORE CALCULATION\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 3.1 Fit logistic regression model
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("3.1 Fitting Logistic Regression Model\n")
cat("------------------------------------------------------------------------------\n")

cat("\nWe model P(AI user) using OBSERVED confounders only:\n")
cat("  P(ai_user = 1) = sigmoid(b0 + b1*prior_exp + b2*quant_skills + b3*stem_background)\n")
cat("\nWe CANNOT include curiosity, tech_readiness, or ai_aversion because\n")
cat("in real life, we wouldn't be able to measure them!\n\n")

psModel <- glm(ai_user ~ prior_exp + quant_skills + stem_background,
               data = df, family = binomial)

print(summary(psModel))

# ------------------------------------------------------------------------------
# 3.2 Extract coefficients
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("3.2 Extracting Coefficients\n")
cat("------------------------------------------------------------------------------\n")

beta0 <- coef(psModel)["(Intercept)"]
beta1 <- coef(psModel)["prior_exp"]
beta2 <- coef(psModel)["quant_skills"]
beta3 <- coef(psModel)["stem_background"]

cat("\nCoefficients:\n")
cat("  b0 (Intercept)       =", round(beta0, 4), "\n")
cat("  b1 (prior_exp)       =", round(beta1, 4), "\n")
cat("  b2 (quant_skills)    =", round(beta2, 4), "\n")
cat("  b3 (stem_background) =", round(beta3, 4), "\n")

# ------------------------------------------------------------------------------
# 3.3 Manual propensity score calculation with for loop
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("3.3 Calculating Propensity Scores Manually\n")
cat("------------------------------------------------------------------------------\n")

pscore <- numeric(n)

cat("\nCalculating propensity score for each student...\n\n")

for (i in 1:n) {
  z <- beta0 + beta1 * df$prior_exp[i] + beta2 * df$quant_skills[i] + beta3 * df$stem_background[i]
  pscore[i] <- sigmoid(z)

  if (i <= 3) {
    cat("Student", i, ":\n")
    cat("  prior_exp =", round(df$prior_exp[i], 2),
        ", quant_skills =", round(df$quant_skills[i], 2),
        ", stem_background =", round(df$stem_background[i], 2), "\n")
    cat("  z =", round(z, 3), "\n")
    cat("  P(AI user) = sigmoid(", round(z, 3), ") =", round(pscore[i], 4), "\n\n")
  }
}

cat("... calculated for all", n, "students\n")

df$pscore <- pscore

# ------------------------------------------------------------------------------
# 3.4 Verify matches glm prediction
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("3.4 Verification\n")
cat("------------------------------------------------------------------------------\n")

glmPred <- predict(psModel, type = "response")
maxDiff <- max(abs(pscore - glmPred))

cat("\nMax difference between manual and glm():", maxDiff, "\n")
if (maxDiff < 1e-10) {
  cat("SUCCESS! Our manual calculation matches glm() exactly.\n")
}

# ------------------------------------------------------------------------------
# 3.5 Visualize propensity score distributions
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("3.5 Propensity Score Distributions\n")
cat("------------------------------------------------------------------------------\n")

df$group <- factor(df$ai_user, labels = c("Non-user", "AI User"))

p4 <- ggplot(df, aes(x = pscore, fill = group)) +
  geom_density(alpha = 0.6) +
  scale_fill_manual(values = c("Non-user" = "steelblue", "AI User" = "coral")) +
  labs(title = "Propensity Score Distributions",
       subtitle = "Overlap = common support region where matching is possible",
       x = "Propensity Score (Predicted P(AI User))",
       y = "Density", fill = "Group") +
  theme_minimal()

print(p4)

cat("\nAI users have higher propensity scores (as expected).\n")
cat("The overlap region is where we can find comparable matches.\n")

# ==============================================================================
# PART 4: MANUAL NEAREST-NEIGHBOR MATCHING
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 4: MANUAL NEAREST-NEIGHBOR MATCHING (WITH CALIPER)\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 4.1 Setup matching
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("4.1 Setting Up Matching\n")
cat("------------------------------------------------------------------------------\n")

df$matched <- 0
df$matchGroup <- NA

treatedIdx <- which(df$ai_user == 1)
controlIdx <- which(df$ai_user == 0)

nTreated <- length(treatedIdx)
nControl <- length(controlIdx)

cat("\nAvailable for matching:\n")
cat("  AI users:", nTreated, "\n")
cat("  Non-users:", nControl, "\n")

# Caliper = 0.2 * SD of propensity scores
caliper <- 0.2 * sd(df$pscore)

cat("\nCaliper (max allowed distance):", round(caliper, 4), "\n")
cat("  = 0.2 * SD(propensity scores)\n")
cat("  If no match within caliper, treated unit is DROPPED.\n")

# ------------------------------------------------------------------------------
# 4.2 Matching loop
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("4.2 Performing Nearest-Neighbor Matching\n")
cat("------------------------------------------------------------------------------\n")

pairID <- 0
droppedCount <- 0

for (i in 1:nTreated) {
  tIdx <- treatedIdx[i]
  tPscore <- df$pscore[tIdx]

  availableControls <- which(df$ai_user == 0 & df$matched == 0)

  if (length(availableControls) == 0) {
    droppedCount <- droppedCount + 1
    next
  }

  bestControlIdx <- NA
  bestDistance <- Inf

  for (cIdx in availableControls) {
    distance <- abs(tPscore - df$pscore[cIdx])
    if (distance < bestDistance) {
      bestDistance <- distance
      bestControlIdx <- cIdx
    }
  }

  # Check caliper
  if (bestDistance > caliper) {
    droppedCount <- droppedCount + 1
    if (droppedCount <= 3) {
      cat("DROPPED: Student", tIdx, "(pscore =", round(tPscore, 4),
          ") - nearest control too far\n")
    }
    next
  }

  # Make match
  pairID <- pairID + 1
  df$matched[tIdx] <- 1
  df$matched[bestControlIdx] <- 1
  df$matchGroup[tIdx] <- pairID
  df$matchGroup[bestControlIdx] <- pairID

  if (pairID <= 3) {
    cat("Pair", pairID, ": Student", tIdx, "(AI user, pscore =", round(tPscore, 4),
        ") matched to Student", bestControlIdx, "(pscore =", round(df$pscore[bestControlIdx], 4), ")\n")
  }
}

cat("\n")
cat("Matching complete!\n")
cat("  Pairs created:", pairID, "\n")
cat("  AI users matched:", sum(df$matched[df$ai_user == 1]), "\n")
cat("  AI users DROPPED:", droppedCount, "\n")

# ------------------------------------------------------------------------------
# 4.3 Create matched dataset
# ------------------------------------------------------------------------------

dfMatched <- df[df$matched == 1, ]

cat("\n------------------------------------------------------------------------------\n")
cat("4.3 Matched Dataset\n")
cat("------------------------------------------------------------------------------\n")
cat("\nOriginal:", n, "students\n")
cat("Matched:", nrow(dfMatched), "students (", nrow(dfMatched)/2, "pairs)\n")

nMatchedTreated <- sum(dfMatched$ai_user == 1)
nMatchedControl <- sum(dfMatched$ai_user == 0)
nDroppedTreated <- sum(df$ai_user == 1) - nMatchedTreated
nDroppedControl <- sum(df$ai_user == 0) - nMatchedControl

cat("\nBreakdown:\n")
cat("  AI users:  ", sum(df$ai_user == 1), "→", nMatchedTreated,
    "(dropped", nDroppedTreated, "due to caliper)\n")
cat("  Non-users: ", sum(df$ai_user == 0), "→", nMatchedControl,
    "(dropped", nDroppedControl, "unmatched)\n")

# Sample size comparison visualization
sampleSizeData <- data.frame(
  dataset = factor(rep(c("Full Data", "Matched Data"), each = 2),
                   levels = c("Full Data", "Matched Data")),
  group = rep(c("AI Users", "Non-Users"), 2),
  count = c(sum(df$ai_user == 1), sum(df$ai_user == 0),
            nMatchedTreated, nMatchedControl)
)

p4b <- ggplot(sampleSizeData, aes(x = dataset, y = count, fill = group)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  geom_text(aes(label = count), position = position_dodge(width = 0.9),
            vjust = -0.5, size = 4) +
  scale_fill_manual(values = c("AI Users" = "coral", "Non-Users" = "steelblue")) +
  labs(title = "Sample Size: Full Data vs Matched Data",
       subtitle = paste0("Matching reduces sample from ", n, " to ", nrow(dfMatched),
                        " (", round(100 * nrow(dfMatched)/n), "% retained)"),
       x = "", y = "Number of Students", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  ylim(0, max(sampleSizeData$count) * 1.15)

print(p4b)

cat("\nTRADE-OFF: Matching improves balance but REDUCES sample size.\n")
cat("           The caliper drops treated units with no good matches.\n")

# ==============================================================================
# PART 5: BALANCE ASSESSMENT
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 5: BALANCE ASSESSMENT\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 5.1 SMD comparison
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.1 Standardized Mean Difference (SMD) Before vs After\n")
cat("------------------------------------------------------------------------------\n")

# Before
smd1_before <- calcSMD(df$prior_exp, df$ai_user)
smd2_before <- calcSMD(df$quant_skills, df$ai_user)
smd3_before <- calcSMD(df$stem_background, df$ai_user)

# After
smd1_after <- calcSMD(dfMatched$prior_exp, dfMatched$ai_user)
smd2_after <- calcSMD(dfMatched$quant_skills, dfMatched$ai_user)
smd3_after <- calcSMD(dfMatched$stem_background, dfMatched$ai_user)

# T-tests BEFORE matching
ttest1_before <- t.test(df$prior_exp[df$ai_user == 1], df$prior_exp[df$ai_user == 0])
ttest2_before <- t.test(df$quant_skills[df$ai_user == 1], df$quant_skills[df$ai_user == 0])
ttest3_before <- t.test(df$stem_background[df$ai_user == 1], df$stem_background[df$ai_user == 0])

# T-tests AFTER matching
ttest1_after <- t.test(dfMatched$prior_exp[dfMatched$ai_user == 1], dfMatched$prior_exp[dfMatched$ai_user == 0])
ttest2_after <- t.test(dfMatched$quant_skills[dfMatched$ai_user == 1], dfMatched$quant_skills[dfMatched$ai_user == 0])
ttest3_after <- t.test(dfMatched$stem_background[dfMatched$ai_user == 1], dfMatched$stem_background[dfMatched$ai_user == 0])

# Create SMD comparison table for OBSERVED confounders
smd_comparison_observed <- data.frame(
  Variable = c("prior_exp", "quant_skills", "stem_background"),
  SMD_Before = round(c(smd1_before, smd2_before, smd3_before), 3),
  p_Before = format(c(ttest1_before$p.value, ttest2_before$p.value, ttest3_before$p.value),
                    scientific = TRUE, digits = 2),
  SMD_After = round(c(smd1_after, smd2_after, smd3_after), 3),
  p_After = format(c(ttest1_after$p.value, ttest2_after$p.value, ttest3_after$p.value),
                   scientific = TRUE, digits = 2),
  Balanced = ifelse(abs(c(smd1_after, smd2_after, smd3_after)) < 0.1, "Yes", "No")
)

cat("\nOBSERVED Confounders:\n")
print(smd_comparison_observed, row.names = FALSE)
cat("\nNote: p < 0.05 means groups are significantly different. After matching, we want p > 0.05!\n")

# ------------------------------------------------------------------------------
# 5.2 Unobserved confounders
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.2 What About UNOBSERVED Confounders?\n")
cat("------------------------------------------------------------------------------\n")

cat("\nSince we simulated this data, we can peek behind the curtain...\n\n")

smd_cur_before <- calcSMD(df$curiosity, df$ai_user)
smd_tech_before <- calcSMD(df$tech_readiness, df$ai_user)
smd_aver_before <- calcSMD(df$ai_aversion, df$ai_user)

smd_cur_after <- calcSMD(dfMatched$curiosity, dfMatched$ai_user)
smd_tech_after <- calcSMD(dfMatched$tech_readiness, dfMatched$ai_user)
smd_aver_after <- calcSMD(dfMatched$ai_aversion, dfMatched$ai_user)

# T-tests BEFORE matching (unobserved)
ttest_cur_before <- t.test(df$curiosity[df$ai_user == 1], df$curiosity[df$ai_user == 0])
ttest_tech_before <- t.test(df$tech_readiness[df$ai_user == 1], df$tech_readiness[df$ai_user == 0])
ttest_aver_before <- t.test(df$ai_aversion[df$ai_user == 1], df$ai_aversion[df$ai_user == 0])

# T-tests AFTER matching (unobserved)
ttest_cur_after <- t.test(dfMatched$curiosity[dfMatched$ai_user == 1], dfMatched$curiosity[dfMatched$ai_user == 0])
ttest_tech_after <- t.test(dfMatched$tech_readiness[dfMatched$ai_user == 1], dfMatched$tech_readiness[dfMatched$ai_user == 0])
ttest_aver_after <- t.test(dfMatched$ai_aversion[dfMatched$ai_user == 1], dfMatched$ai_aversion[dfMatched$ai_user == 0])

# Create SMD comparison table for UNOBSERVED confounders
smd_comparison_unobserved <- data.frame(
  Variable = c("curiosity", "tech_readiness", "ai_aversion"),
  SMD_Before = round(c(smd_cur_before, smd_tech_before, smd_aver_before), 3),
  p_Before = format(c(ttest_cur_before$p.value, ttest_tech_before$p.value, ttest_aver_before$p.value),
                    scientific = TRUE, digits = 2),
  SMD_After = round(c(smd_cur_after, smd_tech_after, smd_aver_after), 3),
  p_After = format(c(ttest_cur_after$p.value, ttest_tech_after$p.value, ttest_aver_after$p.value),
                   scientific = TRUE, digits = 2),
  Balanced = ifelse(abs(c(smd_cur_after, smd_tech_after, smd_aver_after)) < 0.1, "Yes", "No")
)

cat("UNOBSERVED Confounders (we can't control for these!):\n")
print(smd_comparison_unobserved, row.names = FALSE)

cat("\nKEY INSIGHT: Matching on observed confounders does NOT balance unobserved ones!\n")
cat("This is why we'll still have bias in our estimates.\n")

# Create Love plot
lovePlotData <- data.frame(
  variable = rep(c("prior_exp", "quant_skills", "stem_background",
                   "curiosity*", "tech_readiness*", "ai_aversion*"), 2),
  SMD = c(smd1_before, smd2_before, smd3_before, smd_cur_before, smd_tech_before, smd_aver_before,
          smd1_after, smd2_after, smd3_after, smd_cur_after, smd_tech_after, smd_aver_after),
  period = factor(rep(c("Before", "After"), each = 6), levels = c("Before", "After")),
  type = rep(c(rep("Observed", 3), rep("Unobserved", 3)), 2)
)

p5 <- ggplot(lovePlotData, aes(x = abs(SMD), y = variable, color = period, shape = type)) +
  geom_point(size = 4) +
  geom_vline(xintercept = 0.1, linetype = "dashed", color = "green4") +
  geom_vline(xintercept = 0.25, linetype = "dashed", color = "orange") +
  scale_color_manual(values = c("Before" = "coral", "After" = "steelblue")) +
  labs(title = "Love Plot: Balance Before vs After Matching",
       subtitle = "* = Unobserved (cannot be matched on). Matching helps observed, not unobserved.",
       x = "|SMD|", y = "") +
  theme_minimal()

print(p5)

# ------------------------------------------------------------------------------
# 5.3 Box plots: Before vs After Matching
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.3 Visualizing Balance: Box Plots Before vs After Matching\n")
cat("------------------------------------------------------------------------------\n")

# Create combined data for box plots
beforeData <- df[, c("ai_user", "prior_exp", "quant_skills", "stem_background")]
beforeData$period <- "Before Matching"
beforeData$group <- ifelse(beforeData$ai_user == 1, "AI User", "Non-User")

afterData <- dfMatched[, c("ai_user", "prior_exp", "quant_skills", "stem_background")]
afterData$period <- "After Matching"
afterData$group <- ifelse(afterData$ai_user == 1, "AI User", "Non-User")

combinedData <- rbind(beforeData, afterData)
combinedData$period <- factor(combinedData$period, levels = c("Before Matching", "After Matching"))

# Prior experience
p5b <- ggplot(combinedData, aes(x = group, y = prior_exp, fill = group)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ period) +
  scale_fill_manual(values = c("AI User" = "coral", "Non-User" = "steelblue")) +
  labs(title = "Prior Experience: Before vs After Matching",
       subtitle = "Groups should look similar after matching",
       x = "", y = "Years of Experience") +
  theme_minimal() +
  theme(legend.position = "none")

print(p5b)

# Quantitative skills
p5c <- ggplot(combinedData, aes(x = group, y = quant_skills, fill = group)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ period) +
  scale_fill_manual(values = c("AI User" = "coral", "Non-User" = "steelblue")) +
  labs(title = "Quantitative Skills: Before vs After Matching",
       subtitle = "Groups should look similar after matching",
       x = "", y = "Quant Skills (standardized)") +
  theme_minimal() +
  theme(legend.position = "none")

print(p5c)

# STEM background
p5d <- ggplot(combinedData, aes(x = group, y = stem_background, fill = group)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ period) +
  scale_fill_manual(values = c("AI User" = "coral", "Non-User" = "steelblue")) +
  labs(title = "STEM Background: Before vs After Matching",
       subtitle = "Groups should look similar after matching",
       x = "", y = "STEM Affinity Score") +
  theme_minimal() +
  theme(legend.position = "none")

print(p5d)

cat("\nBox plots show the distributions are much more similar after matching!\n")

# ------------------------------------------------------------------------------
# 5.4 Density overlap: Before vs After Matching (Observed)
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.4 Density Overlap: Before vs After Matching\n")
cat("------------------------------------------------------------------------------\n")

cat("\nDensity plots show how distributions converge after matching.\n")

# STEM background - the variable with most imbalance
p5e_stem_before <- ggplot(df, aes(x = stem_background, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "STEM Background: BEFORE Matching",
       subtitle = paste0("SMD = ", round(smd3_before, 2), " (poor balance)"),
       x = "STEM Affinity Score", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

p5e_stem_after <- ggplot(dfMatched, aes(x = stem_background, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "STEM Background: AFTER Matching",
       subtitle = paste0("SMD = ", round(smd3_after, 2), " (good balance!)"),
       x = "STEM Affinity Score", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p5e_stem_before)
print(p5e_stem_after)

cat("\nObserved confounders: Distributions overlap much better after matching!\n")

# ------------------------------------------------------------------------------
# 5.5 Density overlap: UNOBSERVED confounders (Before vs After)
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.5 Density Overlap: UNOBSERVED Confounders (The Problem!)\n")
cat("------------------------------------------------------------------------------\n")

cat("\nNow let's see what happens to unobserved confounders...\n")

# AI Aversion - shows the problem most clearly
p5f_aversion_before <- ggplot(df, aes(x = ai_aversion, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "AI Aversion (UNOBSERVED): BEFORE Matching",
       subtitle = paste0("SMD = ", round(smd_aver_before, 2)),
       x = "AI Aversion Score", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

p5f_aversion_after <- ggplot(dfMatched, aes(x = ai_aversion, fill = factor(ai_user, labels = c("Non-User", "AI User")))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Non-User" = "steelblue", "AI User" = "coral")) +
  labs(title = "AI Aversion (UNOBSERVED): AFTER Matching",
       subtitle = paste0("SMD = ", round(smd_aver_after, 2), " (WORSE!)"),
       x = "AI Aversion Score", y = "Density", fill = "Group") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p5f_aversion_before)
print(p5f_aversion_after)

cat("\nUNOBSERVED confounders: Imbalance gets WORSE after matching!\n")
cat("The caliper dropped AI users with extreme propensity scores,\n")
cat("who happened to have particular unobserved characteristics.\n")
cat("This is why we still have bias in our treatment effect estimates.\n")

# ==============================================================================
# PART 6: TREATMENT EFFECT ESTIMATION
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 6: TREATMENT EFFECT ESTIMATION\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 6.1 Naive estimate
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.1 Method 1: Naive Comparison (No Adjustment)\n")
cat("------------------------------------------------------------------------------\n")

naiveModel <- lm(salary ~ ai_user, data = df)
naiveEst <- coef(naiveModel)["ai_user"]

cat("\nModel: salary ~ ai_user (full sample, n =", nrow(df), ")\n")
cat("Estimate:", round(naiveEst, 4), "($", round(naiveEst * 1000), ")\n", sep = "")
cat("True effect: 2.0000 ($2,000)\n")
cat("Bias:", round(naiveEst - 2, 4), "($", round((naiveEst - 2) * 1000), ")\n", sep = "")

# ------------------------------------------------------------------------------
# 6.2 Regression with covariates (linear only)
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.2 Method 2: Regression with Covariates (Linear Terms Only)\n")
cat("------------------------------------------------------------------------------\n")

regLinearModel <- lm(salary ~ ai_user + prior_exp + quant_skills + stem_background, data = df)
regLinearEst <- coef(regLinearModel)["ai_user"]

cat("\nModel: salary ~ ai_user + prior_exp + quant_skills + stem_background\n")
cat("       (full sample, n =", nrow(df), ", LINEAR terms only)\n")
cat("Estimate:", round(regLinearEst, 4), "($", round(regLinearEst * 1000), ")\n", sep = "")
cat("True effect: 2.0000 ($2,000)\n")
cat("Bias:", round(regLinearEst - 2, 4), "($", round((regLinearEst - 2) * 1000), ")\n", sep = "")

cat("\nProblem: The TRUE outcome model has non-linear terms (prior_exp^2) and\n")
cat("         interactions (quant_skills * stem_background) that we didn't include!\n")

# ------------------------------------------------------------------------------
# 6.3 Matched estimate (no covariates)
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.3 Method 3: Matched Sample (No Covariates)\n")
cat("------------------------------------------------------------------------------\n")

matchedModel <- lm(salary ~ ai_user, data = dfMatched)
matchedEst <- coef(matchedModel)["ai_user"]

cat("\nModel: salary ~ ai_user (matched sample, n =", nrow(dfMatched), ")\n")
cat("Estimate:", round(matchedEst, 4), "($", round(matchedEst * 1000), ")\n", sep = "")
cat("True effect: 2.0000 ($2,000)\n")
cat("Bias:", round(matchedEst - 2, 4), "($", round((matchedEst - 2) * 1000), ")\n", sep = "")

cat("\nMatching doesn't assume linearity - it just compares similar people!\n")

# ------------------------------------------------------------------------------
# 6.4 Matched + covariates
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.4 Method 4: Matched Sample + Covariates (Doubly Robust)\n")
cat("------------------------------------------------------------------------------\n")

matchedCovModel <- lm(salary ~ ai_user + prior_exp + quant_skills + stem_background, data = dfMatched)
matchedCovEst <- coef(matchedCovModel)["ai_user"]

cat("\nModel: salary ~ ai_user + prior_exp + quant_skills + stem_background\n")
cat("       (matched sample, n =", nrow(dfMatched), ")\n")
cat("Estimate:", round(matchedCovEst, 4), "($", round(matchedCovEst * 1000), ")\n", sep = "")
cat("True effect: 2.0000 ($2,000)\n")
cat("Bias:", round(matchedCovEst - 2, 4), "($", round((matchedCovEst - 2) * 1000), ")\n", sep = "")

# ------------------------------------------------------------------------------
# 6.5 Comparison table
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.5 COMPARISON OF ALL METHODS\n")
cat("------------------------------------------------------------------------------\n")

# Calculate bias for each method
naiveBias <- naiveEst - 2
regLinBias <- regLinearEst - 2
matchBias <- matchedEst - 2
matchCovBias <- matchedCovEst - 2

# Calculate bias reduction (relative to naive)
regLinReduc <- round((1 - abs(regLinBias) / abs(naiveBias)) * 100, 1)
matchReduc <- round((1 - abs(matchBias) / abs(naiveBias)) * 100, 1)
matchCovReduc <- round((1 - abs(matchCovBias) / abs(naiveBias)) * 100, 1)

# Create comparison table
methods_comparison <- data.frame(
  Method = c("True Effect", "1. Naive (no cov)", "2. Full + Cov",
             "3. Matching only", "4. Matching + Cov"),
  Estimate = round(c(2.00, naiveEst, regLinearEst, matchedEst, matchedCovEst), 2),
  Bias = round(c(0.00, naiveBias, regLinBias, matchBias, matchCovBias), 2),
  Bias_Reduction = c("-", "-", paste0(regLinReduc, "%"),
                     paste0(matchReduc, "%"), paste0(matchCovReduc, "%"))
)

print(methods_comparison, row.names = FALSE)

# Bar chart
resultsData <- data.frame(
  method = factor(c("True Effect", "Naive (no cov)", "Full + Cov", "Matched", "Matched + Cov"),
                  levels = c("True Effect", "Naive (no cov)", "Full + Cov", "Matched", "Matched + Cov")),
  estimate = c(2, naiveEst, regLinearEst, matchedEst, matchedCovEst)
)

p6 <- ggplot(resultsData, aes(x = method, y = estimate, fill = method)) +
  geom_bar(stat = "identity", alpha = 0.7) +
  geom_hline(yintercept = 2, linetype = "dashed", color = "red", linewidth = 1) +
  scale_fill_manual(values = c("True Effect" = "green4", "Naive (no cov)" = "gray50",
                                "Full + Cov" = "orange", "Matched" = "steelblue",
                                "Matched + Cov" = "purple")) +
  labs(title = "Treatment Effect Estimates by Method",
       subtitle = "Red dashed line = true effect ($2,000). Combining methods works best!",
       x = "", y = "Estimated Effect ($1,000s)") +
  theme_minimal() +
  theme(legend.position = "none", axis.text.x = element_text(angle = 15, hjust = 1))

print(p6)

# ------------------------------------------------------------------------------
# 6.6 Statistical Significance Analysis
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.6 STATISTICAL SIGNIFICANCE ANALYSIS\n")
cat("------------------------------------------------------------------------------\n")

cat("\nLet's examine standard errors, confidence intervals, and p-values.\n")
cat("Remember: True effect = $2,000. Does it fall within our 95% CI?\n\n")

# Extract statistics from each model
# Model 1: Naive
naive_summary <- summary(naiveModel)
naive_se <- naive_summary$coefficients["ai_user", "Std. Error"]
naive_pval <- naive_summary$coefficients["ai_user", "Pr(>|t|)"]
naive_ci <- confint(naiveModel, "ai_user", level = 0.95)

# Model 2: Full + Covariates
regLin_summary <- summary(regLinearModel)
regLin_se <- regLin_summary$coefficients["ai_user", "Std. Error"]
regLin_pval <- regLin_summary$coefficients["ai_user", "Pr(>|t|)"]
regLin_ci <- confint(regLinearModel, "ai_user", level = 0.95)

# Model 3: Matched only
matched_summary <- summary(matchedModel)
matched_se <- matched_summary$coefficients["ai_user", "Std. Error"]
matched_pval <- matched_summary$coefficients["ai_user", "Pr(>|t|)"]
matched_ci <- confint(matchedModel, "ai_user", level = 0.95)

# Model 4: Matched + Covariates
matchedCov_summary <- summary(matchedCovModel)
matchedCov_se <- matchedCov_summary$coefficients["ai_user", "Std. Error"]
matchedCov_pval <- matchedCov_summary$coefficients["ai_user", "Pr(>|t|)"]
matchedCov_ci <- confint(matchedCovModel, "ai_user", level = 0.95)

# Create statistical significance comparison table
stat_sig_table <- data.frame(
  Method = c("1. Naive (no cov)", "2. Full + Cov", "3. Matched only", "4. Matched + Cov"),
  Estimate = round(c(naiveEst, regLinearEst, matchedEst, matchedCovEst), 2),
  SE = round(c(naive_se, regLin_se, matched_se, matchedCov_se), 2),
  p_value = format(c(naive_pval, regLin_pval, matched_pval, matchedCov_pval),
                   scientific = TRUE, digits = 2),
  CI_Low = round(c(naive_ci[1], regLin_ci[1], matched_ci[1], matchedCov_ci[1]), 2),
  CI_High = round(c(naive_ci[2], regLin_ci[2], matched_ci[2], matchedCov_ci[2]), 2),
  True_in_CI = ifelse(c(naive_ci[1] <= 2 & naive_ci[2] >= 2,
                        regLin_ci[1] <= 2 & regLin_ci[2] >= 2,
                        matched_ci[1] <= 2 & matched_ci[2] >= 2,
                        matchedCov_ci[1] <= 2 & matchedCov_ci[2] >= 2), "Yes", "NO")
)

print(stat_sig_table, row.names = FALSE)

cat("\n")
cat("INTERPRETATION:\n")
cat("===============\n\n")

cat("1. ALL methods find a statistically significant effect (p < 0.05).\n")
cat("   This means we'd reject H0: effect = 0 in all cases.\n\n")

cat("2. BUT: The true effect ($2,000) may NOT fall within the 95% CI!\n")
cat("   This shows that statistical significance ≠ unbiased estimation.\n\n")

cat("3. Due to CONFOUNDING BIAS:\n")
cat("   - Our estimates are BIASED (too high)\n")
cat("   - The confidence intervals are centered around the WRONG value\n")
cat("   - Even with tight standard errors, we're precisely WRONG\n\n")

cat("4. KEY LESSON:\n")
cat("   Statistical significance tells us the effect is unlikely to be ZERO.\n")
cat("   It does NOT tell us our estimate is CORRECT or unbiased.\n")
cat("   Unobserved confounding creates bias that p-values cannot detect!\n")

# Visualization: CI plot
ciData <- data.frame(
  method = factor(c("Naive (no cov)", "Full + Cov", "Matched", "Matched + Cov"),
                  levels = c("Naive (no cov)", "Full + Cov", "Matched", "Matched + Cov")),
  estimate = c(naiveEst, regLinearEst, matchedEst, matchedCovEst),
  ci_low = c(naive_ci[1], regLin_ci[1], matched_ci[1], matchedCov_ci[1]),
  ci_high = c(naive_ci[2], regLin_ci[2], matched_ci[2], matchedCov_ci[2])
)

p6b <- ggplot(ciData, aes(x = method, y = estimate, color = method)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2, linewidth = 1) +
  geom_hline(yintercept = 2, linetype = "dashed", color = "red", linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dotted", color = "gray50") +
  scale_color_manual(values = c("Naive (no cov)" = "gray50", "Full + Cov" = "orange",
                                 "Matched" = "steelblue", "Matched + Cov" = "purple")) +
  labs(title = "Treatment Effect Estimates with 95% Confidence Intervals",
       subtitle = "Red dashed line = true effect ($2,000). Does it fall within CI?",
       x = "", y = "Estimated Effect ($1,000s)") +
  theme_minimal() +
  theme(legend.position = "none", axis.text.x = element_text(angle = 15, hjust = 1))

print(p6b)

# ------------------------------------------------------------------------------
# 6.7 Key insight
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.7 KEY INSIGHTS\n")
cat("------------------------------------------------------------------------------\n")

cat("\n")
cat("COMPARING THE METHODS\n")
cat("=====================\n\n")

cat("The true salary model includes NON-LINEAR terms:\n")
cat("  - prior_exp^2 (quadratic effect of experience)\n")
cat("  - quant_skills * stem_background (interaction)\n\n")

cat("Linear regression (Method 2) assumes:\n")
cat("  salary = b0 + b1*ai_user + b2*prior_exp + b3*quant_skills + b4*stem_background\n")
cat("  This is MISSPECIFIED - it misses the non-linear effects!\n\n")

cat("Matching (Method 3) makes NO functional form assumptions:\n")
cat("  It simply compares AI users to similar non-users.\n")
cat("  Doesn't require specifying the correct outcome model.\n\n")

cat("Matching + Covariates (Method 4) - DOUBLY ROBUST:\n")
cat("  Combines the benefits of both approaches.\n")
cat("  Lowest bias because it adjusts for residual imbalance.\n\n")

cat("REMAINING BIAS comes from UNOBSERVED confounders:\n")
cat("  - curiosity, tech_readiness, ai_aversion\n")
cat("  Neither matching nor regression can fix this!\n\n")

cat("BOTTOM LINE:\n")
cat("  - Matching + regression gives best results (doubly robust)\n")
cat("  - Both methods alone achieve similar bias reduction\n")
cat("  - Matching is more ROBUST (doesn't assume functional form)\n")
cat("  - But BOTH methods fail with unobserved confounding\n")
cat("  - Only RANDOMIZATION can balance unobserved confounders\n")

cat("\n==============================================================================\n")
cat("SUMMARY\n")
cat("==============================================================================\n")
cat("\nWhat we learned:\n")
cat("  1. Propensity scores predict treatment probability from observed variables\n")
cat("  2. Matching creates comparable groups without assuming functional form\n")
cat("  3. Combining matching + regression (doubly robust) gives best results\n")
cat("  4. Balance on observed confounders improves after matching (SMD -> 0)\n")
cat("  5. Unobserved confounders remain imbalanced - causing residual bias\n")
cat("  6. Only randomization can balance both observed AND unobserved confounders\n")
cat("==============================================================================\n")
