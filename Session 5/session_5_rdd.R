# =============================================================================
# Session 5: Regression Discontinuity Design
# When Arbitrary Cutoffs Create Natural Experiments
# =============================================================================

rm(list = ls())
library(ggplot2)
library(kableExtra)
library(rdrobust)
library(rddensity)
library(masteringmetrics)

# =============================================================================
# 1. Build Intuition with Simulation
# =============================================================================

# --- 1.1 The Simplest Case: Linear Data with a Jump ---

set.seed(42)
n <- 500

X <- runif(n, -1, 1)
W <- as.integer(X >= 0)
tau <- 3

# DGP: Y = 1 + 2X + 3*W + noise
Y <- 1 + 2 * X + tau * W + rnorm(n, sd = 1)
sim_data <- data.frame(X = X, W = W, Y = Y)

ggplot(sim_data, aes(x = X, y = Y, color = factor(W))) +
  geom_point(alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.8) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_manual(values = c("steelblue", "firebrick"), labels = c("Control", "Treated")) +
  labs(x = "Running Variable (X)", y = "Outcome (Y)",
       title = "Simulated RDD: The Jump IS the Treatment Effect",
       color = "Group") +
  theme_minimal(base_size = 14)

# Estimate with OLS — coefficient on W should be close to 3
m_linear <- lm(Y ~ X + W, data = sim_data)
summary(m_linear)

# --- 1.2 When Linearity Fails: The Nonlinear Case ---

set.seed(314)
n <- 500
X <- runif(n, -1, 1)
W <- as.integer(X >= 0)
tau <- 3

# DGP: Y = 3 + 15X^2 - 8X^3 + 3*W + noise (U-shaped, asymmetric)
Y_nl <- 3 + 15 * X^2 - 8 * X^3 + tau * W + rnorm(n, sd = 2)
sim_nl <- data.frame(X = X, W = W, Y = Y_nl)

ggplot(sim_nl, aes(x = X, y = Y, color = factor(W))) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.8) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", linewidth = 1.2) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = c("steelblue", "firebrick"), labels = c("Control", "Treated")) +
  labs(x = "Running Variable (X)", y = "Outcome (Y)",
       title = "Nonlinear Data: Linear Fit (dashed) vs Loess (solid)",
       subtitle = "The data curves upward on both sides — the straight lines clearly miss this",
       color = "Group") +
  theme_minimal(base_size = 14)

# Naive linear estimate — biased upward (~6.7 instead of 3)
m_naive <- lm(Y ~ X + W, data = sim_nl)
summary(m_naive)

# --- 1.3 Fix 1: Add Polynomial Terms ---

m_poly <- lm(Y ~ X + I(X^2) + I(X^3) + W, data = sim_nl)
summary(m_poly)

# Compare naive vs polynomial
comp <- data.frame(
  Model = c("Linear: Y ~ X + W",
            "Polynomial: Y ~ X + X² + X³ + W"),
  Estimate = c(round(coef(m_naive)["W"], 2),
               round(coef(m_poly)["W"], 2)),
  SE = c(round(summary(m_naive)$coefficients["W", "Std. Error"], 2),
         round(summary(m_poly)$coefficients["W", "Std. Error"], 2)),
  Bias = c(round(coef(m_naive)["W"] - tau, 2),
           round(coef(m_poly)["W"] - tau, 2)),
  R_squared = c(round(summary(m_naive)$r.squared, 3),
                round(summary(m_poly)$r.squared, 3))
)
comp

# Visual comparison: linear vs polynomial fits
X_grid_ctrl <- seq(-1, 0, length.out = 200)
X_grid_trt  <- seq(0, 1, length.out = 200)

m_lin_ctrl <- lm(Y ~ X, data = sim_nl[sim_nl$W == 0, ])
m_lin_trt  <- lm(Y ~ X, data = sim_nl[sim_nl$W == 1, ])

pred_lin_ctrl  <- predict(m_lin_ctrl, newdata = data.frame(X = X_grid_ctrl))
pred_lin_trt   <- predict(m_lin_trt, newdata = data.frame(X = X_grid_trt))
pred_poly_ctrl <- predict(m_poly, newdata = data.frame(X = X_grid_ctrl, W = 0))
pred_poly_trt  <- predict(m_poly, newdata = data.frame(X = X_grid_trt, W = 1))

fit_lines <- rbind(
  data.frame(X = X_grid_ctrl, Y = pred_lin_ctrl, model = "Linear", side = "Control"),
  data.frame(X = X_grid_trt, Y = pred_lin_trt, model = "Linear", side = "Treated"),
  data.frame(X = X_grid_ctrl, Y = pred_poly_ctrl, model = "Polynomial", side = "Control"),
  data.frame(X = X_grid_trt, Y = pred_poly_trt, model = "Polynomial", side = "Treated")
)

ggplot() +
  geom_point(data = sim_nl, aes(x = X, y = Y,
             color = ifelse(W == 1, "Treated", "Control")),
             alpha = 0.25, size = 1.2) +
  geom_line(data = fit_lines, aes(x = X, y = Y, color = side, linetype = model),
            linewidth = 1.1) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.8) +
  scale_color_manual(values = c("Control" = "steelblue", "Treated" = "firebrick")) +
  scale_linetype_manual(values = c("Linear" = "dashed", "Polynomial" = "solid")) +
  labs(x = "Running Variable (X)", y = "Outcome (Y)",
       title = "Linear vs Polynomial Fit",
       subtitle = "The linear fit (dashed) misses the curvature; the polynomial fit (solid) follows the data",
       color = "Group", linetype = "Model") +
  theme_minimal(base_size = 14)

# Model with interaction (different slopes on each side)
m_interact <- lm(Y ~ X + W + X:W, data = sim_nl)
summary(m_interact)

# --- 1.4 Fix 2: Local Regression (The Key Idea) ---

bw <- 0.2
local_data <- sim_nl[abs(sim_nl$X) <= bw, ]

par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))

# Left panel: full data
plot(sim_nl$X, sim_nl$Y,
     col = ifelse(sim_nl$W == 1, adjustcolor("firebrick", 0.4),
                  adjustcolor("steelblue", 0.4)),
     pch = 16, cex = 0.8,
     xlab = "Running Variable (X)", ylab = "Outcome (Y)",
     main = "Full Data — Nonlinearity Is Obvious")
abline(v = 0, lty = 2, lwd = 2)
rect(-bw, par("usr")[3], bw, par("usr")[4],
     col = adjustcolor("gold", 0.15), border = NA)
legend("topleft", legend = c("Control", "Treated", "Bandwidth window"),
       col = c("steelblue", "firebrick", adjustcolor("gold", 0.4)),
       pch = c(16, 16, 15), cex = 0.8, bg = "white")

# Right panel: zoomed into bandwidth
plot(local_data$X, local_data$Y,
     col = ifelse(local_data$W == 1, adjustcolor("firebrick", 0.5),
                  adjustcolor("steelblue", 0.5)),
     pch = 16, cex = 1.2,
     xlab = "Running Variable (X)", ylab = "Outcome (Y)",
     main = paste0("Zoomed In (bw = ±", bw, ") — Looks Linear!"))
abline(v = 0, lty = 2, lwd = 2)
ctrl_local <- local_data[local_data$W == 0, ]
trt_local  <- local_data[local_data$W == 1, ]
if (nrow(ctrl_local) > 2) abline(lm(Y ~ X, data = ctrl_local), col = "steelblue", lwd = 2)
if (nrow(trt_local) > 2) abline(lm(Y ~ X, data = trt_local), col = "firebrick", lwd = 2)

# Local linear estimate
m_local <- lm(Y ~ X + W + X:W, data = local_data)
coef(m_local)["W"]  # should be close to 3

# --- 1.6 The Bias-Variance Tradeoff ---

bandwidths <- c(0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50, 0.60, 0.80, 1.00)

bw_results <- data.frame(
  bandwidth = numeric(0), estimate = numeric(0),
  se = numeric(0), n_obs = integer(0), p_value = numeric(0)
)

for (h in bandwidths) {
  local <- sim_nl[abs(sim_nl$X) <= h, ]
  if (nrow(local) < 6) next
  fit <- lm(Y ~ X + W + X:W, data = local)
  s <- summary(fit)$coefficients
  bw_results <- rbind(bw_results, data.frame(
    bandwidth = h, estimate = coef(fit)["W"],
    se = s["W", "Std. Error"], n_obs = nrow(local),
    p_value = s["W", "Pr(>|t|)"]
  ))
}

bw_results$bias <- bw_results$estimate - tau
bw_results$ci_lower <- bw_results$estimate - 1.96 * bw_results$se
bw_results$ci_upper <- bw_results$estimate + 1.96 * bw_results$se

ggplot(bw_results, aes(x = bandwidth, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = "steelblue") +
  geom_line(linewidth = 1, color = "steelblue") +
  geom_point(aes(size = n_obs), color = "steelblue", alpha = 0.7) +
  geom_hline(yintercept = 3, linetype = "dashed", color = "firebrick", linewidth = 0.8) +
  annotate("text", x = 0.92, y = tau + 0.3, label = "True effect = 3",
           color = "firebrick", fontface = "italic", size = 4) +
  scale_size_continuous(range = c(2, 6), name = "N observations") +
  labs(x = "Bandwidth", y = "Estimated Treatment Effect",
       title = "The Bias-Variance Tradeoff in RDD",
       subtitle = "Narrow = right answer, low power. Wide = wrong answer, high power.") +
  theme_minimal(base_size = 14)

# rdrobust on simulated data
rd_sim <- rdrobust(sim_nl$Y, sim_nl$X, c = 0)
summary(rd_sim)

# =============================================================================
# 2. MLDA & Fatalities — Sharp RDD in Practice
# =============================================================================

data(mlda)

# Rename columns, keep only raw (non-fitted) values
mlda <- data.frame(
  age            = mlda$agecell,
  allCauses      = mlda$all,
  internal       = mlda$internal,
  external       = mlda$external,
  alcoholRelated = mlda$alcohol,
  suicide        = mlda$suicide,
  homicide       = mlda$homicide,
  mva            = mlda$mva,
  drugs          = mlda$drugs
)

head(mlda, 3)

# --- 2.2 Explore the Data ---

death_vars <- c("allCauses", "internal", "external", "mva",
                "alcoholRelated", "suicide", "homicide", "drugs")

# Scatter plots by cause of death
par(mfrow = c(4, 2), mar = c(4, 4, 2, 1))
for (v in death_vars) {
  plot(mlda$age, mlda[[v]], pch = 19, cex = 0.8,
       xlab = "Age", ylab = "Rate per 100,000", main = v,
       col = ifelse(mlda$age >= 21, "firebrick", "steelblue"))
  abline(v = 21, lty = 2, col = "grey50")
}

# --- 2.3 See the Jump ---

ggplot(mlda, aes(x = age, y = allCauses)) +
  geom_point(size = 2.5, color = "grey30") +
  geom_vline(xintercept = 21, linetype = "dashed", color = "firebrick", linewidth = 0.8) +
  geom_smooth(data = subset(mlda, age < 21), method = "lm", se = FALSE,
              color = "steelblue", linewidth = 1) +
  geom_smooth(data = subset(mlda, age >= 21), method = "lm", se = FALSE,
              color = "steelblue", linewidth = 1) +
  labs(x = "Age", y = "Death Rate (per 100,000)",
       title = "All-Cause Mortality Around Age 21",
       subtitle = "Dashed line = MLDA cutoff") +
  theme_minimal(base_size = 14)

# --- 2.4 Manual Estimate with lm() ---
# Using all 48 age cells, centered at age 21

mlda$age_centered <- mlda$age - 21
mlda$over21 <- ifelse(mlda$age >= 21, 1, 0)

m_mlda <- lm(allCauses ~ age_centered + over21, data = mlda)
summary(m_mlda)

# --- 2.5 Allow Different Slopes on Each Side ---

m_mlda_int <- lm(allCauses ~ age_centered * over21, data = mlda)
summary(m_mlda_int)

# --- 2.6 Enter rdrobust ---

rd_mlda <- rdrobust(y = mlda$allCauses, x = mlda$age, c = 21)
summary(rd_mlda)

# Compare all estimates
est1 <- coef(m_mlda)["over21"]
se1  <- summary(m_mlda)$coefficients["over21", "Std. Error"]
est2 <- coef(m_mlda_int)["over21"]
se2  <- summary(m_mlda_int)$coefficients["over21", "Std. Error"]
est3 <- rd_mlda$coef[1]
se3  <- rd_mlda$se[3]

compare_all <- data.frame(
  Method = c("Manual (all data, same slope)",
             "Manual (all data, different slopes)",
             "rdrobust (optimal bandwidth)"),
  Estimate  = round(c(est1, est2, est3), 2),
  SE        = round(c(se1, se2, se3), 2),
  CI_Lower  = round(c(est1 - 1.96*se1, est2 - 1.96*se2, rd_mlda$ci[3, 1]), 2),
  CI_Upper  = round(c(est1 + 1.96*se1, est2 + 1.96*se2, rd_mlda$ci[3, 2]), 2)
)
compare_all

# --- 2.7 Falsification: What Should NOT Jump? ---

# Faceted plot of cause-specific deaths
mlda_long <- rbind(
  data.frame(age = mlda$age, death_rate = mlda$mva,
             cause = "Motor Vehicle Accidents"),
  data.frame(age = mlda$age, death_rate = mlda$internal,
             cause = "Internal Causes"),
  data.frame(age = mlda$age, death_rate = mlda$alcoholRelated,
             cause = "Alcohol-Related"),
  data.frame(age = mlda$age, death_rate = mlda$suicide,
             cause = "Suicide")
)

ggplot(mlda_long, aes(x = age, y = death_rate)) +
  geom_point(size = 1.5, color = "grey30") +
  geom_vline(xintercept = 21, linetype = "dashed", color = "firebrick") +
  geom_smooth(data = subset(mlda_long, age < 21),
              method = "lm", se = FALSE, color = "steelblue") +
  geom_smooth(data = subset(mlda_long, age >= 21),
              method = "lm", se = FALSE, color = "steelblue") +
  facet_wrap(~cause, scales = "free_y", ncol = 1) +
  labs(x = "Age", y = "Death Rate (per 100,000)",
       title = "Falsification: Which Causes of Death Jump at 21?") +
  theme_minimal(base_size = 14)

# rdrobust estimates by cause
causes <- c("mva", "internal", "alcoholRelated", "suicide", "homicide")
cause_labels <- c("Motor Vehicle Accidents", "Internal Causes",
                  "Alcohol-Related", "Suicide", "Homicide")

falsification <- data.frame(
  Cause = character(0), Estimate = numeric(0),
  Robust_SE = numeric(0), Robust_p = numeric(0),
  Significant = character(0)
)

for (i in 1:length(causes)) {
  rd <- rdrobust(y = mlda[[causes[i]]], x = mlda$age, c = 21)
  falsification <- rbind(falsification, data.frame(
    Cause       = cause_labels[i],
    Estimate    = round(rd$coef[1], 3),
    Robust_SE   = round(rd$se[3], 3),
    Robust_p    = round(rd$pv[3], 3),
    Significant = ifelse(rd$pv[3] < 0.05, "Yes", "No")
  ))
}
falsification

# =============================================================================
# 3. Brazil Elections — RDD with rdrobust
# =============================================================================

brazil <- read.csv("CTV_2020_Sage.csv")

names(brazil) <- c("effectiveParties", "margin_t", "margin_t1",
                    "wonPT_lag", "wonPMDB_lag", "wonDEM_lag", "wonPSDB_lag",
                    "population", "gdpPerCapita")
head(brazil, 3)

# Keep only complete cases for running variable + outcome
brazil_clean <- brazil[!is.na(brazil$margin_t) & !is.na(brazil$margin_t1), ]

# Histograms of running variable and outcome
par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))

hist(brazil_clean$margin_t, breaks = 50, col = "steelblue", border = "white",
     main = "Running Variable: Margin at t",
     xlab = "Margin of Victory (pp)")
abline(v = 0, col = "firebrick", lwd = 2, lty = 2)

hist(brazil_clean$margin_t1, breaks = 50, col = "steelblue", border = "white",
     main = "Outcome: Margin at t+1",
     xlab = "Margin of Victory (pp)")
abline(v = 0, col = "firebrick", lwd = 2, lty = 2)

# Define X (running variable) and Y (outcome)
X <- brazil_clean$margin_t
Y <- brazil_clean$margin_t1

# --- 3.2 See the Data ---

ggplot(brazil_clean, aes(x = margin_t, y = margin_t1)) +
  geom_point(alpha = 0.1, size = 0.5, color = "grey50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "firebrick", linewidth = 0.8) +
  geom_smooth(data = subset(brazil_clean, margin_t < 0),
              method = "loess", se = FALSE, color = "steelblue", linewidth = 1) +
  geom_smooth(data = subset(brazil_clean, margin_t >= 0),
              method = "loess", se = FALSE, color = "steelblue", linewidth = 1) +
  labs(x = "Margin of Victory at Election t",
       y = "Margin of Victory at Election t+1",
       title = "Brazil Municipal Elections: The Incumbency Curse",
       subtitle = "Barely winning at t leads to worse performance at t+1") +
  theme_minimal(base_size = 14)

# --- 3.3 Falsification: Density Test (All Parties) ---

dens_test <- rddensity(X)
rdplotdensity(dens_test, X,
              plotRange = c(-50, 50),
              title = "Density of Running Variable Around Cutoff",
              xlabel = "Margin of Victory at t",
              ylabel = "Density")

# Density test by individual party
parties <- c("wonPT_lag", "wonPMDB_lag", "wonDEM_lag", "wonPSDB_lag")
party_names <- c("PT", "PMDB", "DEM", "PSDB")

density_results <- data.frame(
  Party = character(0), N = numeric(0),
  T_stat = numeric(0), P_value = numeric(0)
)

for (i in 1:length(parties)) {
  sub <- brazil_clean[brazil_clean[[parties[i]]] == 1 &
                        !is.na(brazil_clean[[parties[i]]]), ]
  dt <- rddensity(sub$margin_t)
  density_results <- rbind(density_results, data.frame(
    Party   = party_names[i],
    N       = nrow(sub),
    T_stat  = round(dt$test$t_jk, 3),
    P_value = round(dt$test$p_jk, 3)
  ))
}
density_results

# --- 3.4 Falsification: Covariate Balance (GDP) ---

brazil_gdp <- brazil_clean[!is.na(brazil_clean$gdpPerCapita), ]

rd_gdp <- rdrobust(y = brazil_gdp$gdpPerCapita, x = brazil_gdp$margin_t, c = 0)
summary(rd_gdp)

rdplot(y = brazil_gdp$gdpPerCapita, x = brazil_gdp$margin_t, c = 0,
       title = "Covariate Balance: GDP per Capita Around Cutoff",
       x.label = "Margin of Victory at t",
       y.label = "GDP per Capita")

# --- 3.5 Main Estimate ---

rd_brazil <- rdrobust(Y, X, c = 0)
summary(rd_brazil)

rdplot(Y, X, c = 0,
       title = "RD Plot: Effect of Incumbency on Next-Election Margin",
       x.label = "Margin of Victory at t",
       y.label = "Margin of Victory at t+1")

# --- 3.6 Manual Estimate for Comparison ---

brazil_clean$won <- ifelse(brazil_clean$margin_t >= 0, 1, 0)

# Full data — gives WRONG SIGN (+2.07)
m_brazil_full <- lm(margin_t1 ~ margin_t + won, data = brazil_clean)

# Restricted to margin within 20 pp — recovers correct sign (-6.00)
brazil_local <- brazil_clean[abs(brazil_clean$margin_t) <= 20, ]
m_brazil_local <- lm(margin_t1 ~ margin_t + won, data = brazil_local)

compare_brazil <- data.frame(
  Method = c("Manual (all data)", "Manual (margin within 20)", "rdrobust (optimal BW)"),
  Estimate = round(c(coef(m_brazil_full)["won"],
                     coef(m_brazil_local)["won"],
                     rd_brazil$coef[1]), 2),
  SE = round(c(summary(m_brazil_full)$coefficients["won", "Std. Error"],
               summary(m_brazil_local)$coefficients["won", "Std. Error"],
               rd_brazil$se[3]), 2)
)
compare_brazil
