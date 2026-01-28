# ==============================================================================
# Simulation: Randomization, Causality, and Confounding
# Based on Textbook Section 6.2.4 of "Demystifying Causal Inference"
# ==============================================================================

# Load necessary library
if (!require("ggplot2")) install.packages("ggplot2")
library(ggplot2)

# Set seed for reproducibility
set.seed(123)

# Define sample size
ssize <- 900

# ------------------------------------------------------------------------------
# 1. OBSERVATIONAL DATA (Single Run Demonstration)
# ------------------------------------------------------------------------------

# Generate confounding variables
w <- sample(c(0, 1), ssize, replace = TRUE) # Unobserved confounding
z <- rnorm(n = ssize, mean = 5)             # Observed confounding
hist(z)


# Generate Treatment (influenced by w and z)
Tstar <- 30 * w - z + rnorm(n = ssize)
hist(Tstar)
Treat_obs <- ifelse(Tstar > 6.5, 1, 0)

# Generate Outcome (True effect of Treatment = 2)
y_out_obs <- 2 * Treat_obs + 2 * w - z + rnorm(n = ssize)

sim_obs_data <- data.frame(
  y_out = y_out_obs, 
  Treat_obs = Treat_obs, 
  z = z, 
  w = w
)

# Regressions for Observational Data
m1_obs <- lm(y_out ~ Treat_obs, data = sim_obs_data)
m2_obs <- lm(y_out ~ Treat_obs + z, data = sim_obs_data)

# In reality we do not have access to the unobserved variable w
m3_obs <- lm(y_out ~ Treat_obs + z + w, data = sim_obs_data)

summary(m1_obs)
summary(m2_obs)
summary(m3_obs)


print("--- Observational Data Results ---")
print(summary(m1_obs)$coefficients[2, ]) 
print(summary(m2_obs)$coefficients[2, ]) 


# ------------------------------------------------------------------------------
# 2. EXPERIMENTAL DATA (Single Run Demonstration)
# ------------------------------------------------------------------------------

# Generate Treatment randomly (ignoring w and z)
Treat_rand <- sample(c(0, 1), ssize, replace = TRUE)

# Generate Outcome (True effect of Treatment = 2)
y_out_exp <- 2 * Treat_rand + 2 * w + z + rnorm(n = ssize)

sim_exp_data <- data.frame(
  y_out = y_out_exp, 
  Treat_rand = Treat_rand, 
  z = z, 
  w = w)

# Regressions for Experimental Data
m1_exp <- lm(y_out ~ Treat_rand, data = sim_exp_data)
m2_exp <- lm(y_out ~ Treat_rand + z, data = sim_exp_data)

summary(m1_exp)
summary(m2_exp)

print("--- Experimental Data Results ---")
print(summary(m1_exp)$coefficients[2, ]) 
print(summary(m2_exp)$coefficients[2, ]) 


# ------------------------------------------------------------------------------
# 3. SAMPLING DISTRIBUTIONS (For Loop with Data Frames)
# ------------------------------------------------------------------------------

run_sim <- function(n) {
  
  w_sim <- sample(c(0, 1), n, replace = TRUE)
  z_sim <- rnorm(n = n, mean = 5)
  
  # Observational
  Ts <- 3 * w_sim + z_sim + rnorm(n)
  Tr_obs <- ifelse(Ts > 6.5, 1, 0)
  Y_obs <- 2 * Tr_obs + 2 * w_sim + z_sim + rnorm(n)
  
  # Experimental
  Tr_exp <- sample(c(0, 1), n, replace = TRUE)
  Y_exp <- 2 * Tr_exp + 2 * w_sim + z_sim + rnorm(n)
  
  # Use unname() to keep results clean
  return(c(
    obs_no_z   = unname(coef(lm(Y_obs ~ Tr_obs))[2]),
    obs_with_z = unname(coef(lm(Y_obs ~ Tr_obs + z_sim))[2]),
    exp_no_z   = unname(coef(lm(Y_exp ~ Tr_exp))[2]),
    exp_with_z = unname(coef(lm(Y_exp ~ Tr_exp + z_sim))[2])
  ))
  
}

# --- For Loop for N = 900 ---
n_reps <- 1000

# Initialize an empty Data Frame
results_900 <- data.frame(
  obs_no_z   = numeric(n_reps),
  obs_with_z = numeric(n_reps),
  exp_no_z   = numeric(n_reps),
  exp_with_z = numeric(n_reps)
)

for(i in 1:n_reps) {
  results_900[i, ] <- run_sim(900)
}

# --- PLOT: Bias (Fig 6.9) ---
ggplot(results_900) +
  geom_density(aes(x = obs_no_z, color = "Observational"), size = 1) +
  geom_density(aes(x = exp_no_z, color = "Experimental"), size = 1) +
  geom_vline(xintercept = 2, linetype = "dashed") +
  xlim(1.5, 6) +
  labs(title = "Bias: Obs vs Exp (N=900)", 
       x = "Estimated Coefficient", y = "Density", color = "Study Type") +
  theme_minimal() +
  theme(legend.position = "right") +
  scale_color_manual(values = c("Observational" = "red", "Experimental" = "blue"))

# --- PLOT: Precision (Fig 6.10) ---
ggplot(results_900) +
  geom_density(aes(x = exp_no_z, color = "Exp (No Covariate)"), size = 1) +
  geom_density(aes(x = exp_with_z, color = "Exp (With Z)"), size = 1) +
  geom_vline(xintercept = 2, linetype = "dashed") +
  labs(title = "Precision: Adding Covariates", 
       x = "Estimated Coefficient", y = "Density", color = "Model") +
  theme_minimal() +
  theme(legend.position = "right") +
  scale_color_manual(values = c("Exp (No Covariate)" = "blue", "Exp (With Z)" = "darkgreen"))


# ------------------------------------------------------------------------------
# 4. SAMPLE SIZE EFFECTS (Fig 6.11)
# ------------------------------------------------------------------------------

# Initialize empty Data Frame for N = 30
results_30 <- data.frame(
  obs_no_z   = numeric(n_reps),
  obs_with_z = numeric(n_reps),
  exp_no_z   = numeric(n_reps),
  exp_with_z = numeric(n_reps)
)

for(i in 1:n_reps) {
  results_30[i, ] <- run_sim(30)
}

# --- PLOT: Sample Size Comparison ---
ggplot() +
  geom_density(data = results_30, aes(x = exp_no_z, color = "N = 30"), size = 1) +
  geom_density(data = results_900, aes(x = exp_no_z, color = "N = 900"), size = 1) +
  geom_vline(xintercept = 2, linetype = "dashed") +
  xlim(0, 4) +
  labs(title = "Sample Size & Precision", 
       x = "Estimated Coefficient", y = "Density", color = "Sample Size") +
  theme_minimal() +
  theme(legend.position = "right") +
  scale_color_manual(values = c("N = 30" = "orange", "N = 900" = "blue"))
