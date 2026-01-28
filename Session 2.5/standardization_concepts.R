# ==============================================================================
# UNDERSTANDING STANDARDIZATION AND SMD
# ==============================================================================
# This tutorial explains standardization from first principles, building up to
# the Standardized Mean Difference (SMD) used in propensity score matching.
#
# Topics covered:
# 1. What is standardization? (z-scores)
# 2. Manual calculation with for loops
# 3. Using built-in functions (scale())
# 4. Why standardize? (comparing apples to oranges)
# 5. Pooled standard deviation
# 6. Standardized Mean Difference (SMD)
# ==============================================================================

library(ggplot2)

set.seed(123)

# ==============================================================================
# PART 1: WHAT IS STANDARDIZATION?
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 1: WHAT IS STANDARDIZATION?\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 1.1 The problem: Variables have different scales
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("1.1 The Problem: Variables Have Different Scales\n")
cat("------------------------------------------------------------------------------\n")

# Imagine we have data on people:
age <- c(25, 30, 35, 40, 45, 50, 55, 60)       # Age in years (range: 25-60)
income <- c(30, 45, 55, 70, 80, 95, 110, 150)  # Income in thousands (range: 30-150)

cat("\nExample data:\n")
cat("  Age (years):        ", paste(age, collapse = ", "), "\n")
cat("  Income (thousands): ", paste(income, collapse = ", "), "\n")

cat("\nProblem: How do we compare these?\n")
cat("  - Age ranges from 25 to 60 (spread of 35)\n")
cat("  - Income ranges from 30 to 150 (spread of 120)\n")
cat("  - Is a difference of 10 years 'the same' as $10k?\n")
cat("  - We need a common scale!\n")

# ------------------------------------------------------------------------------
# 1.2 The solution: Z-scores (standardization)
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("1.2 The Solution: Z-scores (Standardization)\n")
cat("------------------------------------------------------------------------------\n")

cat("\nStandardization converts any variable to a common scale:\n")
cat("  - Mean becomes 0\n")
cat("  - Standard deviation becomes 1\n")
cat("  - Values are now in 'standard deviation units'\n")

cat("\nThe formula for a z-score:\n")
cat("\n         value - mean\n")
cat("    z = ---------------\n")
cat("        standard deviation\n")

cat("\nInterpretation of z-scores:\n")
cat("  z = 0   : exactly average\n")
cat("  z = 1   : 1 standard deviation above average\n")
cat("  z = -1  : 1 standard deviation below average\n")
cat("  z = 2   : 2 standard deviations above average (unusual)\n")
cat("  z = -2  : 2 standard deviations below average (unusual)\n")

# ==============================================================================
# PART 2: MANUAL CALCULATION WITH FOR LOOPS
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 2: MANUAL CALCULATION WITH FOR LOOPS\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 2.1 Step 1: Calculate the mean
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.1 Step 1: Calculate the Mean\n")
cat("------------------------------------------------------------------------------\n")

# Manual mean calculation for age
n <- length(age)
sumAge <- 0

for (i in 1:n) {
  sumAge <- sumAge + age[i]
}

meanAge <- sumAge / n

cat("\nCalculating mean of age manually:\n")
cat("  Sum of all values:", sumAge, "\n")
cat("  Number of values:", n, "\n")
cat("  Mean = Sum / N =", sumAge, "/", n, "=", meanAge, "\n")

# Verify with built-in function
cat("\n  Verification with mean():", mean(age), "\n")

# ------------------------------------------------------------------------------
# 2.2 Step 2: Calculate the standard deviation
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.2 Step 2: Calculate the Standard Deviation\n")
cat("------------------------------------------------------------------------------\n")

cat("\nStandard deviation measures how spread out the data is.\n")
cat("Formula: SD = sqrt( sum((x - mean)^2) / (n - 1) )\n\n")

# Calculate squared deviations
sumSquaredDev <- 0

cat("Calculating squared deviations from mean:\n")
for (i in 1:n) {
  deviation <- age[i] - meanAge
  squaredDev <- deviation^2
  sumSquaredDev <- sumSquaredDev + squaredDev

  cat("  age[", i, "] =", age[i],
      ", deviation =", age[i], "-", meanAge, "=", round(deviation, 2),
      ", squared =", round(squaredDev, 2), "\n")
}

variance <- sumSquaredDev / (n - 1)  # Note: n-1 for sample variance
sdAge <- sqrt(variance)

cat("\nSum of squared deviations:", round(sumSquaredDev, 2), "\n")
cat("Variance = Sum / (n-1) =", round(sumSquaredDev, 2), "/", n-1, "=", round(variance, 2), "\n")
cat("SD = sqrt(Variance) = sqrt(", round(variance, 2), ") =", round(sdAge, 2), "\n")

# Verify with built-in function
cat("\nVerification with sd():", round(sd(age), 2), "\n")

# ------------------------------------------------------------------------------
# 2.3 Step 3: Calculate z-scores for each value
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("2.3 Step 3: Calculate Z-scores for Each Value\n")
cat("------------------------------------------------------------------------------\n")

# Initialize vector for z-scores
zAge <- numeric(n)

cat("\nApplying z-score formula: z = (value - mean) / SD\n")
cat("Mean =", meanAge, ", SD =", round(sdAge, 2), "\n\n")

for (i in 1:n) {
  zAge[i] <- (age[i] - meanAge) / sdAge

  cat("  age[", i, "] =", age[i],
      ": z = (", age[i], "-", meanAge, ") /", round(sdAge, 2),
      "=", round(zAge[i], 3), "\n")
}

cat("\nOriginal ages:    ", paste(age, collapse = ", "), "\n")
cat("Standardized (z): ", paste(round(zAge, 3), collapse = ", "), "\n")

# Verify properties
cat("\nVerifying z-score properties:\n")
cat("  Mean of z-scores:", round(mean(zAge), 10), "(should be ~0)\n")
cat("  SD of z-scores:", round(sd(zAge), 10), "(should be ~1)\n")

# ==============================================================================
# PART 3: USING BUILT-IN FUNCTIONS
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 3: USING BUILT-IN FUNCTIONS\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 3.1 The scale() function
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("3.1 The scale() Function\n")
cat("------------------------------------------------------------------------------\n")

cat("\nR's scale() function does standardization automatically:\n\n")
cat("  scale(x)                    # Standardize (center and scale)\n")
cat("  scale(x, center = TRUE)     # Subtract the mean\n")
cat("  scale(x, scale = TRUE)      # Divide by SD\n")

# Standardize age using scale()
zAgeBuiltin <- scale(age)

cat("\nUsing scale(age):\n")
cat("  Result:", paste(round(zAgeBuiltin, 3), collapse = ", "), "\n")

cat("\nCompare to our manual calculation:\n")
cat("  Manual:", paste(round(zAge, 3), collapse = ", "), "\n")

# Check if they match
maxDiff <- max(abs(zAge - as.vector(zAgeBuiltin)))
cat("\nMaximum difference:", maxDiff, "\n")
if (maxDiff < 1e-10) {
  cat("SUCCESS! Manual calculation matches scale() exactly.\n")
}

# ------------------------------------------------------------------------------
# 3.2 Standardizing multiple variables
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("3.2 Standardizing Multiple Variables\n")
cat("------------------------------------------------------------------------------\n")

# Create a data frame
df <- data.frame(age = age, income = income)

cat("\nOriginal data:\n")
print(df)

# Standardize both columns
dfStd <- as.data.frame(scale(df))

cat("\nStandardized data:\n")
print(round(dfStd, 3))

cat("\nNow both variables are on the same scale!\n")
cat("We can directly compare: a z-score of 1.5 means the same thing\n")
cat("for both age and income (1.5 SDs above average).\n")

# ==============================================================================
# PART 4: WHY STANDARDIZE? (VISUAL DEMONSTRATION)
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 4: WHY STANDARDIZE? (VISUAL DEMONSTRATION)\n")
cat("==============================================================================\n")

# Create larger sample for visualization
set.seed(456)
n_large <- 200

# Generate data with very different scales
height_cm <- rnorm(n_large, mean = 170, sd = 10)    # Height: 150-190 cm
weight_kg <- rnorm(n_large, mean = 70, sd = 15)     # Weight: 40-100 kg
salary_k <- rnorm(n_large, mean = 50, sd = 20)      # Salary: 10-90 thousand

# Create comparison plot - BEFORE standardization
plotDataBefore <- data.frame(
  value = c(height_cm, weight_kg, salary_k),
  variable = rep(c("Height (cm)", "Weight (kg)", "Salary ($k)"), each = n_large)
)

p1 <- ggplot(plotDataBefore, aes(x = variable, y = value, fill = variable)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "BEFORE Standardization",
       subtitle = "Variables have completely different scales - hard to compare",
       x = "", y = "Value (original units)") +
  theme_minimal() +
  theme(legend.position = "none")

print(p1)

# Standardize all three
height_z <- scale(height_cm)
weight_z <- scale(weight_kg)
salary_z <- scale(salary_k)

# Create comparison plot - AFTER standardization
plotDataAfter <- data.frame(
  value = c(height_z, weight_z, salary_z),
  variable = rep(c("Height (z)", "Weight (z)", "Salary (z)"), each = n_large)
)

p2 <- ggplot(plotDataAfter, aes(x = variable, y = value, fill = variable)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "AFTER Standardization",
       subtitle = "All variables now on same scale (standard deviations from mean)",
       x = "", y = "Z-score (standard deviations)") +
  theme_minimal() +
  theme(legend.position = "none") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red")

print(p2)

cat("\nAfter standardization:\n")
cat("  - All variables have mean = 0 and SD = 1\n")
cat("  - We can now compare 'apples to oranges'\n")
cat("  - A person with z = 2 for height is equally unusual as z = 2 for salary\n")

# ==============================================================================
# PART 5: POOLED STANDARD DEVIATION
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 5: POOLED STANDARD DEVIATION\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 5.1 The problem: Two groups with different SDs
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.1 The Problem: Two Groups with Different SDs\n")
cat("------------------------------------------------------------------------------\n")

# Create two groups with different variability
set.seed(789)
group1 <- rnorm(50, mean = 100, sd = 10)  # Less variable
group2 <- rnorm(50, mean = 110, sd = 20)  # More variable

cat("\nExample: Test scores from two schools\n")
cat("\nSchool 1:\n")
cat("  Mean:", round(mean(group1), 2), "\n")
cat("  SD:", round(sd(group1), 2), "\n")

cat("\nSchool 2:\n")
cat("  Mean:", round(mean(group2), 2), "\n")
cat("  SD:", round(sd(group2), 2), "\n")

cat("\nQuestion: How different are these groups?\n")
cat("Problem: They have different SDs. Which SD should we use to standardize?\n")

# ------------------------------------------------------------------------------
# 5.2 Solution: Pooled standard deviation
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.2 Solution: Pooled Standard Deviation\n")
cat("------------------------------------------------------------------------------\n")

cat("\nPooled SD combines the variability from both groups.\n")
cat("It's like asking: 'What's the typical spread across both groups combined?'\n")

cat("\nSimple formula (equal group sizes):\n")
cat("\n  Pooled SD = sqrt( (SD1^2 + SD2^2) / 2 )\n")

# Calculate pooled SD
sd1 <- sd(group1)
sd2 <- sd(group2)

pooledSD <- sqrt((sd1^2 + sd2^2) / 2)

cat("\nCalculation:\n")
cat("  SD1 =", round(sd1, 2), ", SD1^2 =", round(sd1^2, 2), "\n")
cat("  SD2 =", round(sd2, 2), ", SD2^2 =", round(sd2^2, 2), "\n")
cat("  Average of variances: (", round(sd1^2, 2), "+", round(sd2^2, 2), ") / 2 =",
    round((sd1^2 + sd2^2) / 2, 2), "\n")
cat("  Pooled SD = sqrt(", round((sd1^2 + sd2^2) / 2, 2), ") =", round(pooledSD, 2), "\n")

cat("\nNote: Pooled SD (", round(pooledSD, 2), ") is between SD1 (", round(sd1, 2),
    ") and SD2 (", round(sd2, 2), ")\n")

# ------------------------------------------------------------------------------
# 5.3 Why not just average the SDs?
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("5.3 Why Not Just Average the SDs?\n")
cat("------------------------------------------------------------------------------\n")

simpleAvg <- (sd1 + sd2) / 2

cat("\nYou might think: just average the SDs directly?\n")
cat("  Simple average: (", round(sd1, 2), "+", round(sd2, 2), ") / 2 =", round(simpleAvg, 2), "\n")
cat("  Pooled SD:", round(pooledSD, 2), "\n")

cat("\nThey're different! Why use pooled SD?\n")
cat("  - Variance (SD^2) is additive, SD is not\n")
cat("  - Pooled SD properly accounts for the spread in each group\n")
cat("  - It's the mathematically correct way to combine variability\n")

# ==============================================================================
# PART 6: STANDARDIZED MEAN DIFFERENCE (SMD)
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 6: STANDARDIZED MEAN DIFFERENCE (SMD)\n")
cat("==============================================================================\n")

# ------------------------------------------------------------------------------
# 6.1 What is SMD?
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.1 What is SMD?\n")
cat("------------------------------------------------------------------------------\n")

cat("\nSMD measures how different two groups are, in standard deviation units.\n")

cat("\nFormula:\n")
cat("\n         Mean(Group 1) - Mean(Group 2)\n")
cat("  SMD = ---------------------------------\n")
cat("                 Pooled SD\n")

cat("\nInterpretation:\n")
cat("  SMD = 0    : Groups have identical means\n")
cat("  SMD = 0.2  : Small difference (0.2 SDs apart)\n")
cat("  SMD = 0.5  : Medium difference (0.5 SDs apart)\n")
cat("  SMD = 0.8  : Large difference (0.8 SDs apart)\n")
cat("  SMD = 1.0  : Very large (the means are 1 full SD apart)\n")

# ------------------------------------------------------------------------------
# 6.2 Manual SMD calculation
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.2 Manual SMD Calculation\n")
cat("------------------------------------------------------------------------------\n")

# Using our school example
mean1 <- mean(group1)
mean2 <- mean(group2)
meanDiff <- mean1 - mean2

cat("\nUsing our school example:\n")
cat("  Mean(School 1):", round(mean1, 2), "\n")
cat("  Mean(School 2):", round(mean2, 2), "\n")
cat("  Difference:", round(meanDiff, 2), "\n")
cat("  Pooled SD:", round(pooledSD, 2), "\n")

smd <- meanDiff / pooledSD

cat("\n  SMD =", round(meanDiff, 2), "/", round(pooledSD, 2), "=", round(smd, 3), "\n")

cat("\nInterpretation: The schools differ by", round(abs(smd), 2), "standard deviations.\n")
if (abs(smd) < 0.2) {
  cat("This is a SMALL difference.\n")
} else if (abs(smd) < 0.5) {
  cat("This is a SMALL-to-MEDIUM difference.\n")
} else if (abs(smd) < 0.8) {
  cat("This is a MEDIUM difference.\n")
} else {
  cat("This is a LARGE difference.\n")
}

# ------------------------------------------------------------------------------
# 6.3 SMD function for reuse
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.3 Creating a Reusable SMD Function\n")
cat("------------------------------------------------------------------------------\n")

# Define the function
calcSMD <- function(x, groupIndicator) {
  # x: the variable to compare
  # groupIndicator: 0/1 indicator for which group each observation belongs to

  # Step 1: Calculate means for each group
  mean1 <- mean(x[groupIndicator == 1])
  mean0 <- mean(x[groupIndicator == 0])

  # Step 2: Calculate SDs for each group
  sd1 <- sd(x[groupIndicator == 1])
  sd0 <- sd(x[groupIndicator == 0])

  # Step 3: Calculate pooled SD
  pooledSD <- sqrt((sd1^2 + sd0^2) / 2)

  # Step 4: Calculate SMD
  smd <- (mean1 - mean0) / pooledSD

  return(smd)
}

cat("\nFunction definition:\n")
cat("
calcSMD <- function(x, groupIndicator) {
  mean1 <- mean(x[groupIndicator == 1])
  mean0 <- mean(x[groupIndicator == 0])
  sd1 <- sd(x[groupIndicator == 1])
  sd0 <- sd(x[groupIndicator == 0])
  pooledSD <- sqrt((sd1^2 + sd0^2) / 2)
  smd <- (mean1 - mean0) / pooledSD
  return(smd)
}
")

# ------------------------------------------------------------------------------
# 6.4 SMD in propensity score matching context
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("6.4 SMD in Propensity Score Matching\n")
cat("------------------------------------------------------------------------------\n")

# Create example treatment/control data
set.seed(123)
n_obs <- 200

# Confounded data: treatment depends on age
age_sim <- rnorm(n_obs, mean = 40, sd = 10)
treat_prob <- plogis(-2 + 0.05 * age_sim)  # Higher age -> more likely treated
treatment <- rbinom(n_obs, 1, treat_prob)

cat("\nIn propensity score matching, we use SMD to check BALANCE.\n\n")

cat("Example: Age distribution in treated vs control groups\n")
cat("  Treated group mean age:", round(mean(age_sim[treatment == 1]), 2), "\n")
cat("  Control group mean age:", round(mean(age_sim[treatment == 0]), 2), "\n")

smd_age <- calcSMD(age_sim, treatment)
cat("  SMD:", round(smd_age, 3), "\n")

cat("\nBalance thresholds commonly used:\n")
cat("  |SMD| < 0.1  : Good balance (groups are similar)\n")
cat("  |SMD| < 0.25 : Acceptable balance\n")
cat("  |SMD| > 0.25 : Poor balance (groups are too different)\n")

if (abs(smd_age) > 0.25) {
  cat("\nWith SMD =", round(smd_age, 3), ", we have POOR balance.\n")
  cat("This means age is confounded with treatment.\n")
  cat("We need matching to fix this!\n")
} else if (abs(smd_age) > 0.1) {
  cat("\nWith SMD =", round(smd_age, 3), ", we have ACCEPTABLE but not ideal balance.\n")
} else {
  cat("\nWith SMD =", round(smd_age, 3), ", we have GOOD balance.\n")
}

# ==============================================================================
# PART 7: VISUAL SUMMARY
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 7: VISUAL SUMMARY\n")
cat("==============================================================================\n")

# Create visualization showing different SMD values
set.seed(42)
n_demo <- 500

# Generate groups with different SMDs
smd_examples <- data.frame(
  value = c(
    rnorm(n_demo, mean = 0, sd = 1),    # Control (SMD = 0)
    rnorm(n_demo, mean = 0, sd = 1),    # Treatment group 1
    rnorm(n_demo, mean = 0, sd = 1),    # Control (SMD = 0.5)
    rnorm(n_demo, mean = 0.5, sd = 1),  # Treatment group 2
    rnorm(n_demo, mean = 0, sd = 1),    # Control (SMD = 1.0)
    rnorm(n_demo, mean = 1.0, sd = 1)   # Treatment group 3
  ),
  group = rep(c("Control", "Treated"), times = 3, each = n_demo),
  scenario = rep(c("SMD = 0 (Perfect Balance)",
                   "SMD = 0.5 (Medium Imbalance)",
                   "SMD = 1.0 (Severe Imbalance)"), each = 2 * n_demo)
)

p3 <- ggplot(smd_examples, aes(x = value, fill = group)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ scenario, ncol = 1) +
  scale_fill_manual(values = c("Control" = "steelblue", "Treated" = "coral")) +
  labs(title = "What Different SMD Values Look Like",
       subtitle = "SMD measures how far apart the distributions are",
       x = "Value (standardized)", y = "Density",
       fill = "Group") +
  theme_minimal()

print(p3)

# ==============================================================================
# SUMMARY
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("SUMMARY: KEY CONCEPTS\n")
cat("==============================================================================\n")

cat("\n1. STANDARDIZATION (Z-SCORE)\n")
cat("   - Converts any variable to mean=0, SD=1\n")
cat("   - Formula: z = (value - mean) / SD\n")
cat("   - Allows comparing variables with different scales\n")

cat("\n2. POOLED STANDARD DEVIATION\n")
cat("   - Combines variability from two groups\n")
cat("   - Formula: pooled_SD = sqrt((SD1^2 + SD2^2) / 2)\n")
cat("   - Used when groups have different spreads\n")

cat("\n3. STANDARDIZED MEAN DIFFERENCE (SMD)\n")
cat("   - Measures group difference in SD units\n")
cat("   - Formula: SMD = (mean1 - mean2) / pooled_SD\n")
cat("   - Thresholds: <0.1 good, <0.25 acceptable, >0.25 poor\n")

cat("\n4. WHY SMD MATTERS FOR MATCHING\n")
cat("   - Before matching: SMD shows imbalance (confounding)\n")
cat("   - After matching: SMD should decrease (balance improved)\n")
cat("   - Goal: |SMD| < 0.1 for all covariates\n")

cat("\n==============================================================================\n")

# ==============================================================================
# PART 8: SMD vs STATISTICAL SIGNIFICANCE (P-VALUES)
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 8: SMD vs STATISTICAL SIGNIFICANCE\n")
cat("==============================================================================\n")

cat("\nIMPORTANT: SMD is NOT the same as statistical significance!\n")

# ------------------------------------------------------------------------------
# 8.1 What SMD tells you
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("8.1 What SMD Actually Tells You\n")
cat("------------------------------------------------------------------------------\n")

cat("\nSMD tells you HOW DIFFERENT two groups are, measured in standard deviations.\n")

cat("\nThink of it as 'overlap' between distributions:\n")
cat("  SMD = 0.0 : Distributions completely overlap (identical groups)\n")
cat("  SMD = 0.5 : Moderate overlap (50% of observations distinguishable)\n")
cat("  SMD = 1.0 : Little overlap (means are 1 SD apart)\n")
cat("  SMD = 2.0 : Almost no overlap (means are 2 SDs apart)\n")

cat("\nVisual intuition:\n")
cat("  - If two normal distributions have SMD = 2, about 97.7% of the treated\n")
cat("    group is above the control group mean.\n")
cat("  - If SMD = 1, about 84% of treated is above control mean.\n")
cat("  - If SMD = 0.5, about 69% of treated is above control mean.\n")

# ------------------------------------------------------------------------------
# 8.2 The key difference: SMD vs p-values
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("8.2 The Key Difference: SMD vs P-values\n")
cat("------------------------------------------------------------------------------\n")

cat("\nP-VALUES depend on SAMPLE SIZE:\n")
cat("  - With n=10, even a large difference might not be 'significant'\n")
cat("  - With n=10,000, even a tiny difference becomes 'significant'\n")

cat("\nSMD does NOT depend on sample size:\n")
cat("  - SMD = 0.5 means the same thing whether n=10 or n=10,000\n")
cat("  - It's a measure of EFFECT SIZE, not statistical significance\n")

cat("\nThe relationship between them:\n")
cat("  For a two-sample t-test with equal groups:\n")
cat("    t-statistic ≈ SMD × sqrt(n/2)\n")
cat("  where n is the total sample size.\n")

# ------------------------------------------------------------------------------
# 8.3 Demonstration: Same SMD, Different P-values
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("8.3 Demonstration: Same SMD, Different P-values\n")
cat("------------------------------------------------------------------------------\n")

cat("\nLet's create data with SMD ≈ 0.5 but different sample sizes:\n\n")

set.seed(999)

# Small sample
n_small <- 20
g1_small <- rnorm(n_small/2, mean = 0, sd = 1)
g2_small <- rnorm(n_small/2, mean = 0.5, sd = 1)  # SMD ≈ 0.5
smd_small <- (mean(g2_small) - mean(g1_small)) / sqrt((sd(g1_small)^2 + sd(g2_small)^2) / 2)
ttest_small <- t.test(g2_small, g1_small)

# Medium sample
n_med <- 100
g1_med <- rnorm(n_med/2, mean = 0, sd = 1)
g2_med <- rnorm(n_med/2, mean = 0.5, sd = 1)
smd_med <- (mean(g2_med) - mean(g1_med)) / sqrt((sd(g1_med)^2 + sd(g2_med)^2) / 2)
ttest_med <- t.test(g2_med, g1_med)

# Large sample
n_large <- 1000
g1_large <- rnorm(n_large/2, mean = 0, sd = 1)
g2_large <- rnorm(n_large/2, mean = 0.5, sd = 1)
smd_large <- (mean(g2_large) - mean(g1_large)) / sqrt((sd(g1_large)^2 + sd(g2_large)^2) / 2)
ttest_large <- t.test(g2_large, g1_large)

# Create comparison table
smd_vs_pvalue <- data.frame(
  Sample_Size = c(n_small, n_med, n_large),
  SMD = round(c(smd_small, smd_med, smd_large), 3),
  p_value = format(c(ttest_small$p.value, ttest_med$p.value, ttest_large$p.value),
                   scientific = TRUE, digits = 2),
  Significant = ifelse(c(ttest_small$p.value, ttest_med$p.value, ttest_large$p.value) < 0.05,
                       "YES", "NO")
)

print(smd_vs_pvalue, row.names = FALSE)

cat("CONCLUSION:\n")
cat("  All three have similar SMD (~0.5), but very different p-values!\n")
cat("  With large samples, EVERYTHING becomes 'statistically significant'.\n")

# ------------------------------------------------------------------------------
# 8.4 Why we use SMD for balance (not p-values)
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("8.4 Why We Use SMD for Balance (Not P-values)\n")
cat("------------------------------------------------------------------------------\n")

cat("\nIn propensity score matching, we check BALANCE using SMD, not p-values.\n")

cat("\nWhy?\n")
cat("  1. P-values are confounded by sample size\n")
cat("     - Large studies show 'significant' imbalance even for tiny differences\n")
cat("     - Small studies might miss substantial imbalance\n\n")

cat("  2. SMD tells you the PRACTICAL importance of imbalance\n")
cat("     - SMD = 0.01 is trivial, even if p < 0.001 with large n\n")
cat("     - SMD = 0.50 is substantial, even if p > 0.05 with small n\n\n")

cat("  3. SMD has intuitive thresholds that don't change with sample size\n")
cat("     - |SMD| < 0.1  : Good balance (groups practically identical)\n")
cat("     - |SMD| < 0.25 : Acceptable balance\n")
cat("     - |SMD| > 0.25 : Poor balance (confounding likely)\n")

# ------------------------------------------------------------------------------
# 8.5 Visual: Same SMD, Different Sample Sizes
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("8.5 Visualization: Same SMD, Different Statistical Significance\n")
cat("------------------------------------------------------------------------------\n")

# Create data for visualization - build each sample separately
vizSmall <- data.frame(
  value = c(g1_small, g2_small),
  group = rep(c("Control", "Treated"), each = n_small/2),
  sample = "n=20"
)

vizMed <- data.frame(
  value = c(g1_med, g2_med),
  group = rep(c("Control", "Treated"), each = n_med/2),
  sample = "n=100"
)

vizLarge <- data.frame(
  value = c(g1_large[1:100], g2_large[1:100]),  # Subsample for visualization
  group = rep(c("Control", "Treated"), each = 100),
  sample = "n=1000"
)

vizData <- rbind(vizSmall, vizMed, vizLarge)
vizData$sample <- factor(vizData$sample, levels = c("n=20", "n=100", "n=1000"))

p4 <- ggplot(vizData, aes(x = value, fill = group)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ sample, ncol = 1) +
  scale_fill_manual(values = c("Control" = "steelblue", "Treated" = "coral")) +
  labs(title = "Same SMD (~0.5), Different P-values Due to Sample Size",
       subtitle = "Larger n → smaller p-value, but SMD stays the same",
       x = "Value", y = "Density") +
  theme_minimal()

print(p4)

# ------------------------------------------------------------------------------
# 8.6 The bottom line
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("8.6 The Bottom Line\n")
cat("------------------------------------------------------------------------------\n")

cat("\nSMD answers: 'How different are these groups?'\n")
cat("  - Independent of sample size\n")
cat("  - Measured in standard deviations\n")
cat("  - Has practical, intuitive thresholds\n")

cat("\nP-value answers: 'Could this difference be due to chance?'\n")
cat("  - Heavily dependent on sample size\n")
cat("  - Doesn't tell you HOW different the groups are\n")
cat("  - A tiny difference can be 'highly significant' with large n\n")

cat("\nFor BALANCE assessment in matching:\n")
cat("  USE SMD - it tells you if groups are practically similar\n")
cat("  DON'T rely on p-values - they'll mislead you with large samples\n")

cat("\n==============================================================================\n")

# ==============================================================================
# PART 9: CAN WE STANDARDIZE CATEGORICAL VARIABLES?
# ==============================================================================

cat("\n")
cat("==============================================================================\n")
cat("PART 9: CAN WE STANDARDIZE CATEGORICAL VARIABLES?\n")
cat("==============================================================================\n")

cat("\nThis is an important question! Not all variables can be standardized.\n")

# ------------------------------------------------------------------------------
# 9.1 Types of categorical variables
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("9.1 Types of Categorical Variables\n")
cat("------------------------------------------------------------------------------\n")

cat("\nCategorical variables come in two main types:\n")
cat("\n  1. NOMINAL (no natural order):\n")
cat("     - Colors: red, blue, green\n")
cat("     - Country: USA, France, Japan\n")
cat("     - Gender: male, female, other\n")
cat("     - Major: economics, political science, engineering\n")

cat("\n  2. ORDINAL (natural order exists):\n")
cat("     - Education: high school < bachelor's < master's < PhD\n")
cat("     - Satisfaction: very dissatisfied < dissatisfied < neutral < satisfied < very satisfied\n")
cat("     - Income bracket: low < medium < high\n")
cat("     - Pain level: none < mild < moderate < severe\n")

# ------------------------------------------------------------------------------
# 9.2 Why nominal variables CANNOT be standardized
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("9.2 Why NOMINAL Variables CANNOT Be Standardized\n")
cat("------------------------------------------------------------------------------\n")

cat("\nStandardization requires:\n")
cat("  z = (value - mean) / SD\n")

cat("\nFor this formula to make sense, you need:\n")
cat("  1. Meaningful arithmetic (can you subtract 'blue' from 'red'?)\n")
cat("  2. A meaningful mean (what's the 'average' of red, blue, green?)\n")
cat("  3. A meaningful distance (is blue '2 units' from red?)\n")

cat("\nExample: Favorite color\n")
cat("  - If we code: red=1, blue=2, green=3\n")
cat("  - Mean = 2 (blue?) - this is MEANINGLESS!\n")
cat("  - The numbers are just arbitrary labels\n")
cat("  - Changing to red=5, blue=10, green=15 would give different 'z-scores'\n")

cat("\nCONCLUSION: You CANNOT standardize nominal variables.\n")
cat("            The numbers assigned to categories are arbitrary.\n")

# ------------------------------------------------------------------------------
# 9.3 Can ordinal variables be standardized?
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("9.3 Can ORDINAL Variables Be Standardized?\n")
cat("------------------------------------------------------------------------------\n")

cat("\nOrdinal variables have ORDER but not equal INTERVALS.\n")

cat("\nExample: Education level\n")
cat("  - High school (1) < Bachelor's (2) < Master's (3) < PhD (4)\n")
cat("  - We know 4 > 3 > 2 > 1\n")
cat("  - But is the 'gap' from HS to Bachelor's the same as Master's to PhD?\n")
cat("  - Probably not! These intervals are NOT necessarily equal.\n")

cat("\nThe problem:\n")
cat("  - Standardization assumes equal intervals\n")
cat("  - z = 1 means '1 SD above mean'\n")
cat("  - This assumes moving 1 unit anywhere on the scale means the same thing\n")

cat("\nIN PRACTICE (with caution):\n")
cat("  - Many researchers DO standardize ordinal variables\n")
cat("  - Especially with many categories (e.g., Likert 1-7)\n")
cat("  - It's an approximation that often works reasonably well\n")
cat("  - But be aware of the assumption being made!\n")

# ------------------------------------------------------------------------------
# 9.4 What to do instead for categorical variables
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("9.4 What To Do Instead for Categorical Variables\n")
cat("------------------------------------------------------------------------------\n")

cat("\nFor NOMINAL variables in balance checking:\n")
cat("  - Compare PROPORTIONS in each category between groups\n")
cat("  - Use chi-squared test for overall difference\n")
cat("  - Report percentage in each category by treatment group\n")

cat("\nFor BINARY variables (special case of nominal):\n")
cat("  - SMD CAN be calculated for binary variables!\n")
cat("  - Formula: SMD = (p1 - p0) / sqrt(p*(1-p))\n")
cat("  - Where p1, p0 are proportions in each group\n")
cat("  - And p is the pooled proportion\n")

# Demonstrate with binary variable
set.seed(456)
n_demo <- 200

# Create confounded treatment assignment based on a binary variable
is_stem <- rbinom(n_demo, 1, 0.4)  # 40% are STEM majors
treat_prob <- 0.3 + 0.4 * is_stem  # STEM more likely to be treated
treatment <- rbinom(n_demo, 1, treat_prob)

# Calculate proportions
p1 <- mean(is_stem[treatment == 1])  # Proportion STEM in treated
p0 <- mean(is_stem[treatment == 0])  # Proportion STEM in control
p_pooled <- mean(is_stem)

# SMD for binary variable
smd_binary <- (p1 - p0) / sqrt(p_pooled * (1 - p_pooled))

cat("\nExample: Binary variable (is_stem: 0 or 1)\n")

binary_balance <- data.frame(
  Group = c("Treated", "Control", "Difference"),
  Proportion_STEM = c(round(p1, 3), round(p0, 3), round(p1 - p0, 3)),
  SMD = c("-", "-", round(smd_binary, 3))
)
print(binary_balance, row.names = FALSE)

cat("\nThe SMD of", round(smd_binary, 3), "tells us STEM majors are overrepresented\n")
cat("in the treated group (imbalance that needs fixing).\n")

# ------------------------------------------------------------------------------
# 9.5 Summary table
# ------------------------------------------------------------------------------

cat("\n------------------------------------------------------------------------------\n")
cat("9.5 Summary: What Can Be Standardized?\n")
cat("------------------------------------------------------------------------------\n")

summary_table <- data.frame(
  Variable_Type = c("Continuous", "Binary (0/1)", "Ordinal", "Nominal"),
  Can_Standardize = c("YES", "YES (modified)", "MAYBE (with caution)", "NO"),
  Notes = c("Standard z-score formula",
            "Use proportion-based SMD formula",
            "Assumes equal intervals (often violated)",
            "No meaningful arithmetic on categories")
)

print(summary_table, row.names = FALSE)

cat("\nKEY TAKEAWAY:\n")
cat("  - Continuous & binary: Standardize and use SMD\n")
cat("  - Ordinal: Can approximate, but interpret carefully\n")
cat("  - Nominal: Cannot standardize - compare proportions instead\n")

cat("\n==============================================================================\n")
