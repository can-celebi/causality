# ==============================================================================
# CAUSAL GRAPH SIMULATIONS
# Demonstrating different causal structures and when to control for variables
# ==============================================================================

library(tidyverse)

set.seed(12345)

# ==============================================================================
# 1. SIMPLE CAUSAL RELATIONSHIP (A → B)
# ==============================================================================
# Structure: A directly causes B, no confounding
# What we expect: Regression of B on A gives us the true causal effect

# 1. SIMPLE CAUSAL RELATIONSHIP (A → B)
# Here we demonstrate the simplest causal structure where A directly causes B
# with no confounding. A simple regression should recover the true effect.

n <- 1000
A <- rnorm(n, mean = 100, sd = 15)
B <- 50 + 0.75 * A + rnorm(n, mean = 0, sd = 10)

# Fit the regression
model_simple <- lm(B ~ A)

# Display results
# Display regression results
cat("Coefficient for A:", round(coef(model_simple)[2], 4), " (true value: 0.75)\n")


# ==============================================================================
# 2. FORK / CONFOUNDER (A → B and A → C)
# ==============================================================================
# Structure: A causes both B and C (A is a common cause / confounder)
# What we expect:
#   - Without controlling for A: B and C appear correlated (spurious)
#   - Controlling for A: B and C have no correlation (correct)
# Key lesson: MUST control for the confounder

# 2. FORK / CONFOUNDER (A → B and A → C)
# Education is a common cause that affects both income and health.
# If we don't control for education, income and health will appear correlated
# even though income doesn't directly cause health.

n <- 1000
A <- rnorm(n, mean = 14, sd = 3)    # Education (in years)
B <- 20000 + 5000 * A + rnorm(n, mean = 0, sd = 8000)  # Income (dollars)
C <- 50 + 2 * A + rnorm(n, mean = 0, sd = 5)           # Health score

# WRONG: Without education control
model_fork_wrong <- lm(C ~ B)
cat("Without education control - Income effect:", round(coef(model_fork_wrong)[2], 6), "\n")

# CORRECT: With education control
model_fork_correct <- lm(C ~ B + A)
cat("With education control - Income effect:", round(coef(model_fork_correct)[2], 6), "\n")


# ==============================================================================
# 3. CHAIN / MEDIATOR (A → B → C)
# ==============================================================================
# Structure: A causes B, B causes C (B is the mechanism/mediator)
# What we expect:
#   - Without controlling for B: We see the TOTAL effect of A on C
#   - Controlling for B: We block the pathway, effect disappears
# Key lesson: Do NOT control for the mediator (you'll kill the effect)

# 3. CHAIN / MEDIATOR (A → B → C)
# Exercise affects fitness, and fitness affects life satisfaction.
# The mechanism is: exercise → fitness → satisfaction
# If we control for fitness, we block this mechanism.

n <- 1000
A <- rnorm(n, mean = 5, sd = 2)      # Exercise (hours per week)
B <- 30 + 4 * A + rnorm(n, mean = 0, sd = 5)  # Fitness score
C <- 40 + 1.5 * B + rnorm(n, mean = 0, sd = 6)  # Life satisfaction

# CORRECT: Without fitness control (total effect)
model_chain_correct <- lm(C ~ A)
cat("Without fitness control - Exercise effect:", round(coef(model_chain_correct)[2], 4), "\n")

# WRONG: With fitness control (blocks the mechanism)
model_chain_wrong <- lm(C ~ A + B)
cat("With fitness control - Exercise effect:", round(coef(model_chain_wrong)[2], 4), "\n")


# ==============================================================================
# 4. COLLIDER (B → A ← C)
# ==============================================================================
# Structure: Both B and C cause A (A is a collider)
# B and C are independent, but conditioning on A creates spurious correlation
# Key lesson: Do NOT control for the collider (you'll create bias where none exists)

# 4. COLLIDER (B → A ← C)
# Both programming and communication skills independently cause job offers.
# In the full population, these skills are uncorrelated.
# But if we condition on getting a job offer, they become negatively correlated!

n <- 1000
B <- rnorm(n, mean = 50, sd = 10)    # Programming skill (independent)
C <- rnorm(n, mean = 50, sd = 10)    # Communication skill (independent)
A <- (B + C > 95) * 1  # Got job offer if combined skills exceed threshold

# Full population - skills are independent
cor_bc_overall <- cor(B, C)
cat("Full population - Correlation:", round(cor_bc_overall, 3), "\n")

# Among hired - spurious negative correlation
got_offer <- A == 1
B_offer <- B[got_offer]
C_offer <- C[got_offer]
cor_bc_conditional <- cor(B_offer, C_offer)
cat("Among hired - Correlation:", round(cor_bc_conditional, 3), "\n")

# Regression among hired
df_offer <- data.frame(B = B_offer, C = C_offer)
model_collider <- lm(C ~ B, data = df_offer)
cat("Effect of programming on communication (hired only):", round(coef(model_collider)[2], 4), "\n")

cat("\n" %+% paste(rep("=", 78), collapse = ""))
