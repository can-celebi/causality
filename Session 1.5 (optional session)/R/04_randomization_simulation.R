# ==============================================================================
# RANDOMIZATION ENABLES CAUSALITY: Observational vs Experimental Data
# ==============================================================================
#
# CORE IDEA:
# In observational data, treatment selection depends on confounders.
# This creates bias: we can't tell if the outcome improved because of treatment,
# or because treated people were different to begin with.
#
# Randomization SOLVES this by making treatment independent of confounders.
# Random assignment breaks the confounding path, giving unbiased estimates.
#
# Reference: Textbook pp. 92-96 (Section: "Simulate to Understand")
# ==============================================================================

library(tidyverse)
library(ggplot2)

set.seed(7777)

# ==============================================================================
# PART 1: OBSERVATIONAL DATA WITH CONFOUNDING
# ==============================================================================
#
# SETUP: Medical treatment study
# - We want to estimate the effect of treatment on health outcomes
# - Two confounders exist:
#   1. Initial health (W): sicker people seek treatment more
#   2. Motivation (Z): motivated people seek treatment AND recover better anyway
# - These confounders create bias in our estimate
#

# Generate the confounding variables
n <- 500
W <- rnorm(n, mean = 50, sd = 15)  # Initial health: ranges 0-100
Z <- rnorm(n, mean = 50, sd = 15)  # Motivation: ranges 0-100

# Treatment assignment DEPENDS on confounders (this is confounding!)
# Sicker people (low W) and more motivated people (high Z) get treatment
prob_treatment <- plogis(-2 + 0.04 * (100 - W) + 0.02 * Z)
T_obs <- rbinom(n, size = 1, prob = prob_treatment)

# Outcome model: outcome depends on initial health, motivation, AND treatment
# True causal effect of treatment: 5 points
# But initial health and motivation also directly affect the outcome
Y_obs <- 30 + 0.3 * W + 0.4 * Z + 5 * T_obs + rnorm(n, mean = 0, sd = 5)
Y_obs <- pmin(pmax(Y_obs, 0), 100)  # Keep in range [0, 100]

# Assemble dataset
obs_data <- data.frame(
  id = 1:n,
  initial_health = W,
  motivation = Z,
  treatment = T_obs,
  outcome = Y_obs
)

# Check what happened with treatment assignment
cat("Observational data summary:\n")
cat("N =", nrow(obs_data), "\n")
cat("Treated:", sum(obs_data$treatment), "Control:", sum(obs_data$treatment == 0), "\n\n")

# Key indicator of confounding: are treated and control groups balanced on covariates?
treated <- obs_data$treatment == 1
control <- obs_data$treatment == 0

cat("Are treatment groups balanced (signs of confounding if not)?\n")
cat("Initial health  - Treated:", round(mean(obs_data$initial_health[treated]), 1),
    " vs Control:", round(mean(obs_data$initial_health[control]), 1), "\n")
cat("Motivation      - Treated:", round(mean(obs_data$motivation[treated]), 1),
    " vs Control:", round(mean(obs_data$motivation[control]), 1), "\n\n")

# Now fit regressions to see the bias problem
# Model 1: NAIVE - Don't control for any confounders
model_obs_naive <- lm(outcome ~ treatment, data = obs_data)
summary(model_obs_naive)

# Model 2: PARTIAL - Control for one confounder
model_obs_partial <- lm(outcome ~ treatment + motivation, data = obs_data)
summary(model_obs_partial)

# Model 3: FULL - Control for both confounders
model_obs_full <- lm(outcome ~ treatment + initial_health + motivation, data = obs_data)
summary(model_obs_full)


cat("KEY INSIGHT: We only get the right answer when we control for ALL confounders.\n")
cat("In reality, we never know what all the confounders are!\n")
cat("This is why observational data is unreliable for causal inference.\n\n")


# ==============================================================================
# PART 2: RANDOMIZED EXPERIMENT - THE SOLUTION
# ==============================================================================
#
# SETUP: Same population and outcome model, but now treatment is RANDOMLY assigned
# - Random coin flip: 50% get treatment, 50% get control
# - Treatment is independent of confounders
# - This breaks the confounding path
#

# Use the SAME confounders W and Z (same people in this simulation)
# But now assignment is random, not confounded

T_exp <- rbinom(n, size = 1, prob = 0.5)  # Coin flip: 50/50 random assignment

# Outcome follows SAME causal model (treatment still has true effect = 5)
Y_exp <- 30 + 0.3 * W + 0.4 * Z + 5 * T_exp + rnorm(n, mean = 0, sd = 5)
Y_exp <- pmin(pmax(Y_exp, 0), 100)

# Assemble dataset
exp_data <- data.frame(
  id = 1:n,
  initial_health = W,
  motivation = Z,
  treatment = T_exp,
  outcome = Y_exp
)

cat("Randomized experiment summary:\n")
cat("N =", nrow(exp_data), "\n")
cat("Treated:", sum(exp_data$treatment), "Control:", sum(exp_data$treatment == 0), "\n\n")

# Check balance - should be much better because of random assignment
treated_exp <- exp_data$treatment == 1
control_exp <- exp_data$treatment == 0

cat("Are treatment groups balanced? (should be YES after randomization)\n")
cat("Initial health  - Treated:", round(mean(exp_data$initial_health[treated_exp]), 1),
    " vs Control:", round(mean(exp_data$initial_health[control_exp]), 1), "\n")
cat("Motivation      - Treated:", round(mean(exp_data$motivation[treated_exp]), 1),
    " vs Control:", round(mean(exp_data$motivation[control_exp]), 1), "\n\n")

# Fit regressions
# Even WITHOUT controlling for confounders, we should get the right answer!
model_exp_simple <- lm(outcome ~ treatment, data = exp_data)
summary(model_exp_simple)

# With covariates - improves precision, not needed for bias
model_exp_with_controls <- lm(outcome ~ treatment + initial_health + motivation, data = exp_data)
summary(model_exp_with_controls)


cat("KEY INSIGHT: Both estimates are close to the true effect!\n")
cat("Adding covariates doesn't change the estimate, just improves precision.\n")
cat("We get the right answer because randomization broke the confounding.\n\n")








# ==============================================================================
# PART 3: COMPARING SAMPLING DISTRIBUTIONS
# ==============================================================================
#
# QUESTION: Are the estimates really different?
# Let's run both designs 500 times and look at the distributions of estimates.
# This shows us:
# - Observational: consistently biased
# - Experimental: centered on true value
#

n_sims <- 500
sample_size <- 200

coef_obs_naive <- numeric(n_sims)
coef_exp_simple <- numeric(n_sims)

# Run simulations
for (i in 1:n_sims) {
  # OBSERVATIONAL DATA (confounded treatment)
  W_sim <- rnorm(sample_size, mean = 50, sd = 15)
  Z_sim <- rnorm(sample_size, mean = 50, sd = 15)
  prob_sim <- plogis(-2 + 0.04 * (100 - W_sim) + 0.02 * Z_sim)
  T_obs_sim <- rbinom(sample_size, size = 1, prob = prob_sim)
  Y_obs_sim <- 30 + 0.3 * W_sim + 0.4 * Z_sim + 5 * T_obs_sim + rnorm(sample_size, sd = 5)

  model_obs_sim <- lm(Y_obs_sim ~ T_obs_sim)
  coef_obs_naive[i] <- coef(model_obs_sim)["T_obs_sim"]

  # EXPERIMENTAL DATA (random assignment)
  T_exp_sim <- rbinom(sample_size, size = 1, prob = 0.5)
  Y_exp_sim <- 30 + 0.3 * W_sim + 0.4 * Z_sim + 5 * T_exp_sim + rnorm(sample_size, sd = 5)

  model_exp_sim <- lm(Y_exp_sim ~ T_exp_sim)
  coef_exp_simple[i] <- coef(model_exp_sim)["T_exp_sim"]
}

# Summarize results
cat("Simulation results (500 runs, n=200 per run):\n\n")

obs_mean <- mean(coef_obs_naive)
obs_sd <- sd(coef_obs_naive)
cat("OBSERVATIONAL:\n")
cat("  Mean estimate:  ", round(obs_mean, 4), "\n")
cat("  Bias:           ", round(obs_mean - 5, 4), "\n")
cat("  Std deviation:  ", round(obs_sd, 4), "\n\n")

exp_mean <- mean(coef_exp_simple)
exp_sd <- sd(coef_exp_simple)
cat("EXPERIMENTAL:\n")
cat("  Mean estimate:  ", round(exp_mean, 4), "\n")
cat("  Bias:           ", round(exp_mean - 5, 4), "\n")
cat("  Std deviation:  ", round(exp_sd, 4), "\n\n")

# Visualization
sim_results <- data.frame(
  estimate = c(coef_obs_naive, coef_exp_simple),
  type = rep(c("Observational\n(Confounded)", "Experimental\n(Randomized)"), each = n_sims)
)

plot_dist <- ggplot(sim_results, aes(x = estimate, fill = type)) +
  geom_density(alpha = 0.6) +
  geom_vline(xintercept = 5, color = "red", linetype = "dashed", linewidth = 1) +
  labs(
    title = "Sampling Distributions: Observational vs Experimental",
    subtitle = "500 simulations each, sample size = 200",
    x = "Estimated Treatment Effect",
    y = "Density",
    fill = "Design"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(plot_dist)

cat("VISUALIZATION: The red dashed line is the true effect (5).\n")
cat("- Observational estimates: concentrated around 4-7 (BIASED)\n")
cat("- Experimental estimates: concentrated around 5 (UNBIASED)\n\n")


# ==============================================================================
# PART 4: EFFECT OF SAMPLE SIZE ON PRECISION
# ==============================================================================
#
# QUESTION: Does sample size fix bias?
# We'll try different sample sizes and see what happens.
# Key finding: sample size improves PRECISION, not BIAS
#

sample_sizes <- c(50, 100, 200, 500)
n_sims_ss <- 200

results_ss <- list()

for (ss_idx in seq_along(sample_sizes)) {
  ss <- sample_sizes[ss_idx]

  coef_obs_ss <- numeric(n_sims_ss)
  coef_exp_ss <- numeric(n_sims_ss)

  for (i in 1:n_sims_ss) {
    # Observational
    W_sim <- rnorm(ss, mean = 50, sd = 15)
    Z_sim <- rnorm(ss, mean = 50, sd = 15)
    prob_sim <- plogis(-2 + 0.04 * (100 - W_sim) + 0.02 * Z_sim)
    T_obs_sim <- rbinom(ss, size = 1, prob = prob_sim)
    Y_obs_sim <- 30 + 0.3 * W_sim + 0.4 * Z_sim + 5 * T_obs_sim + rnorm(ss, sd = 5)

    model_obs_sim <- lm(Y_obs_sim ~ T_obs_sim)
    coef_obs_ss[i] <- coef(model_obs_sim)["T_obs_sim"]

    # Experimental
    T_exp_sim <- rbinom(ss, size = 1, prob = 0.5)
    Y_exp_sim <- 30 + 0.3 * W_sim + 0.4 * Z_sim + 5 * T_exp_sim + rnorm(ss, sd = 5)

    model_exp_sim <- lm(Y_exp_sim ~ T_exp_sim)
    coef_exp_ss[i] <- coef(model_exp_sim)["T_exp_sim"]
  }

  results_ss[[ss_idx]] <- data.frame(
    sample_size = ss,
    type = rep(c("Observational", "Experimental"), each = n_sims_ss),
    estimate = c(coef_obs_ss, coef_exp_ss)
  )
}

results_all_ss <- do.call(rbind, results_ss)

# Summary statistics
summary_ss <- results_all_ss %>%
  group_by(sample_size, type) %>%
  summarize(
    mean = mean(estimate),
    bias = mean(estimate) - 5,
    sd = sd(estimate),
    .groups = 'drop'
  )

cat("Sample size effects:\n")
print(summary_ss)

cat("\nKEY FINDINGS:\n")
cat("1. BIAS doesn't change with sample size (observational stays biased)\n")
cat("2. PRECISION improves with sample size (estimates get tighter)\n")
cat("3. Only RANDOMIZATION eliminates bias\n\n")

# Visualization
plot_ss <- ggplot(results_all_ss, aes(x = factor(sample_size), y = estimate, fill = type)) +
  geom_boxplot(alpha = 0.7) +
  geom_hline(yintercept = 5, color = "red", linetype = "dashed", linewidth = 1) +
  labs(
    title = "Effect of Sample Size on Bias and Precision",
    x = "Sample Size",
    y = "Estimated Treatment Effect",
    fill = "Design"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(plot_ss)

cat("VISUALIZATION: Observational bias persists across all sample sizes.\n")
cat("Experimental estimates remain unbiased regardless of sample size.\n\n")


# ==============================================================================
# SUMMARY: KEY LESSONS
# ==============================================================================

cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")
cat("KEY LESSONS: WHY RANDOMIZATION MATTERS FOR CAUSAL INFERENCE\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n\n")

cat("1. CONFOUNDING IN OBSERVATIONAL DATA\n")
cat("   - Treatment selection depends on confounders\n")
cat("   - Simple regression gives BIASED estimates\n")
cat("   - Bias persists no matter how large the sample\n\n")

cat("2. RANDOMIZATION SOLVES THE PROBLEM\n")
cat("   - Random assignment is independent of confounders\n")
cat("   - Even simple regression gives UNBIASED estimates\n")
cat("   - Works without knowing or measuring confounders!\n\n")

cat("3. BIAS vs PRECISION ARE DIFFERENT PROBLEMS\n")
cat("   - Sample size affects PRECISION (narrower confidence intervals)\n")
cat("   - Sample size does NOT affect BIAS\n")
cat("   - Larger samples don't fix confounding\n\n")

cat("4. COVARIATES IN EXPERIMENTS\n")
cat("   - Random assignment already ensures unbiasedness\n")
cat("   - Adding controls improves PRECISION (tighter estimates)\n")
cat("   - But it doesn't change the estimate itself\n\n")

cat("5. WHY RCTs ARE THE GOLD STANDARD\n")
cat("   - Randomization breaks confounding paths\n")
cat("   - You get unbiased estimates WITHOUT controlling for confounders\n")
cat("   - This is why Randomized Controlled Trials are so powerful\n\n")
