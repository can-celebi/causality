# =============================================================================
# Textbook Code Reference — Chapter 9: Regression Discontinuity Design
# Dayal & Murugesan (2023), "Mastering 'Metrics with R", pp. 169–192
# =============================================================================
# This file extracts and comments the R code from the textbook §9.3.
# It serves as raw material for the teaching Rmd — NOT meant to be run as-is.

# -----------------------------------------------------------------------------
# §9.3.1  MLDA — Minimum Legal Drinking Age (Sharp RDD)
# -----------------------------------------------------------------------------
# Data from Carpenter & Dobkin (2009): death rates by age cell around age 21

library(masteringmetrics)
library(rdrobust)
library(tidyverse)

data(mlda)

# "all" = all-cause death rate per 100,000
# "agecell" = age in years (running variable; cutoff = 21)
# Also has: internal, external, mva, alcohol, suicide, homicide, drugs

# --- Basic scatter with loess ---
ggplot(mlda, aes(x = agecell, y = all)) +
  geom_point() +
  geom_vline(xintercept = 21, linetype = "dashed") +
  geom_smooth()

# --- Manual RDD with lm() ---
# Center the running variable at the cutoff
mlda <- mlda %>% mutate(over21 = as.integer(agecell >= 21))
m1 <- lm(all ~ agecell + over21, data = mlda)
summary(m1)
# Textbook reports: over21 coefficient ≈ 9.55 (jump in death rate at 21)

# --- rdrobust ---
rd1 <- rdrobust(y = mlda$all, x = mlda$agecell, c = 21)
summary(rd1)


# -----------------------------------------------------------------------------
# §9.3.2  Brazil Municipal Elections (Sharp RDD)
# -----------------------------------------------------------------------------
# Data from Cattaneo, Titiunik & Vazquez-Bare (2020)
# Originally: Klašnja & Titiunik (2017, APSR) — "incumbency curse"

data <- read.csv("CTV_2020_Sage.csv")

Y <- data$mv_incpartyfor1   # outcome: margin of victory at t+1
X <- data$mv_incparty       # running variable: margin of victory at t

# --- Density test (manipulation check) ---
library(rddensity)
dens <- rddensity(X)
summary(dens)
rdplotdensity(dens, X)

# --- Covariate balance (falsification) ---
# GDP per capita should NOT jump at cutoff
rdrobust(y = data$pibpc, x = X, c = 0)

# --- Main RD estimate ---
rd2 <- rdrobust(Y, X, c = 0)
summary(rd2)
# Effect ≈ -6.3: barely winning HURTS next-election performance ("incumbency curse")

# --- RD plot ---
rdplot(Y, X, c = 0)


# -----------------------------------------------------------------------------
# §9.3.4  Simulation — Understanding Bandwidth and Polynomials
# -----------------------------------------------------------------------------

set.seed(42)
n <- 1000
X <- runif(n, -1, 1)
W <- as.integer(X >= 0)        # treatment indicator
tau <- 3                       # true treatment effect

# --- Linear DGP ---
Y_lin <- 1 + 2*X + tau*W + rnorm(n)
lm(Y_lin ~ X + W)             # recovers tau ≈ 3

# --- Quadratic DGP (nonlinear) ---
Y_quad <- 1 + 2*X + 3*X^2 + tau*W + rnorm(n)
lm(Y_quad ~ X + W)            # biased — doesn't account for curvature
lm(Y_quad ~ X + I(X^2) + W)   # better — includes quadratic term

# --- Local regression (restrict bandwidth) ---
bw <- 0.25
local_data <- data.frame(X, Y_quad, W) %>% filter(abs(X) <= bw)
lm(Y_quad ~ X + W, data = local_data)  # close to tau=3 within narrow window

# --- rdrobust on simulated data ---
rdrobust(Y_quad, X, c = 0)
