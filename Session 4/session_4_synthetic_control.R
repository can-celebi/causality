# ==============================================================================
# Session 4: The Synthetic Control Method
# Economic Costs of German Reunification
# ==============================================================================
# When no single country is a good counterfactual for a treated country, SCM
# constructs a synthetic version as a weighted average of untreated donors —
# matched on pre-treatment characteristics and outcome trajectory.
#
# Case study: Abadie, Diamond, and Hainmueller (2015) — did German
# reunification (1990) hurt West Germany's economy?

rm(list = ls())
library(foreign)
library(Synth)
library(tidyverse)
library(kableExtra)


# ==============================================================================
# 1. The Data
# ==============================================================================
# Original dataset from Abadie, Diamond, and Hainmueller (2015).

d <- read.dta("repgermany.dta")
glimpse(d)

# 17 OECD countries (16 donors + West Germany), 1960-2003.
# West Germany (index = 7) is the treated unit.

colnames(d)
head(d, 3)

# The first three columns define the panel structure:
#   Column 1 (index):   numeric country ID. West Germany is index = 7.
#   Column 2 (country): human-readable country name.
#   Column 3 (year):    time period.
#
# When we call dataprep() later, unit.variable = 1 and time.variable = 3
# refer to COLUMN POSITIONS (1st and 3rd columns), not index values.

# --- Variable Definitions ---
#
# gdp:       GDP per capita (PPP, constant 2002 USD). Source: Penn World Tables.
#            Full 1960-2003 for all countries. Both outcome and predictor.
#
# trade:     Trade openness = (exports + imports) / GDP, as %. Source: World Bank WDI.
#            Germany stops at 1990 (trade stats merged after reunification).
#
# infrate:   Annual inflation rate (% change CPI, base 1995). Source: OECD.
#            Germany stops at 1999 (euro replaced the Deutsche Mark).
#
# industry:  Industry share of value added (% of GDP). Source: World Bank WDI.
#            Sparse pre-1971. Germany: isolated 1960 point, gap, then 1970-1989.
#
# schooling: % of pop 25+ who attained secondary school. Source: Barro-Lee.
#            Quinquennial (every 5 years). Germany: 1960-1990 (7 data points).
#
# invest80:  Real domestic investment / real GDP. Source: Penn World Tables.
#            Single 1980 cross-section — one number per country.

# Rename abbreviated variable names to be more descriptive
d <- d %>% rename(
  tradeOpenness   = trade,
  inflationRate   = infrate,
  industryShare   = industry,
  secondarySchool = schooling
)


# ==============================================================================
# 2. Explore the Variables
# ==============================================================================
# Each plot shows all countries in grey with Germany in red.
# The dashed line marks reunification (1990).

plot_var <- function(data, var, title) {
  ggplot(data %>% filter(!is.na(.data[[var]])),
         aes(x = year, y = .data[[var]], group = country)) +
    geom_line(color = "grey75", alpha = 0.6) +
    geom_line(data = data %>% filter(country == "West Germany", !is.na(.data[[var]])),
              color = "red", linewidth = 1.2) +
    geom_vline(xintercept = 1990, linetype = "dashed", alpha = 0.4) +
    labs(title = title, x = "Year", y = var) +
    theme_minimal()
}

# GDP per capita: our outcome variable. Germany tracks near the top of OECD
# before reunification. After 1990: would it have continued on that trajectory?
plot_var(d, "gdp", "GDP per Capita (Outcome Variable)")

# Trade openness: Germany's red line stops at 1990 — after reunification,
# separate West German trade stats weren't available. GDP continues because
# it was reconstructed for West German states using regional accounts.
plot_var(d, "tradeOpenness", "Trade Openness (% of GDP)")

# Inflation rate: Germany's series ends 1999 — the euro replaced the
# Deutsche Mark, so separate German CPI becomes meaningless.
plot_var(d, "inflationRate", "Inflation Rate (Annual % Change in CPI)")

# Industry share of value added: sparse before 1971. Note isolated 1960
# data point for Germany, then gap before consistent coverage ~1970-71.
plot_var(d, "industryShare", "Industry Share of Value Added (% of GDP)")

# Secondary school attainment: Barro-Lee quinquennial data (every 5 years).
# Lines look like staircases. Germany's series: 1960-1990.
plot_var(d, "secondarySchool", "Secondary School Attainment (% of Pop 25+)")

# Investment rate (~1980): single cross-sectional snapshot, not a time series.
d %>%
  filter(!is.na(invest80)) %>%
  distinct(country, invest80) %>%
  mutate(is_germany = country == "West Germany") %>%
  ggplot(aes(x = reorder(country, invest80), y = invest80, fill = is_germany)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "grey75")) +
  coord_flip() +
  labs(title = "Investment Rate (~1980)", x = NULL, y = "Investment Rate") +
  theme_minimal()


# ==============================================================================
# 3. Countries as Vectors
# ==============================================================================
# Core idea: collapse each country's time series into a single vector of
# predictor values, then measure how similar each donor is to Germany.
#
# Why Euclidean distance?
# We want absolute differences, not proportional ones.
# d = sqrt( sum( (a_i - b_i)^2 ) )
#
# Example: 2 predictors (GDP in thousands, inflation in %).
#   Austria (20, 3), Japan (18, 5), Germany (22, 2)
#   Austria distance: sqrt((22-20)^2 + (2-3)^2) = sqrt(5) = 2.24
#   Japan distance:   sqrt((22-18)^2 + (2-5)^2) = sqrt(25) = 5.0
#   Austria is closer — makes sense.
#
# Critical: we standardize (subtract mean, divide by SD) before computing
# distances. Otherwise GDP (thousands) dominates inflation (single digits).

# Collapse each country's time series into one number per predictor by
# averaging over 1981-1990. Exceptions: invest80 is already a single 1980
# value, secondarySchool is quinquennial so we average 1980 and 1985.
pred_summary <- d %>%
  filter(year %in% 1981:1990) %>%
  group_by(country) %>%
  summarise(gdp = mean(gdp, na.rm = TRUE),
            tradeOpenness = mean(tradeOpenness, na.rm = TRUE),
            inflationRate = mean(inflationRate, na.rm = TRUE),
            industryShare = mean(industryShare, na.rm = TRUE),
            .groups = "drop") %>%
  left_join(d %>% filter(year == 1980) %>% select(country, invest80), by = "country") %>%
  left_join(d %>% filter(year %in% c(1980, 1985)) %>% group_by(country) %>%
              summarise(secondarySchool = mean(secondarySchool, na.rm = TRUE),
                        .groups = "drop"),
            by = "country")

# Each country is now a point in 6-dimensional predictor space.
# Convert to matrix, standardize, extract Germany's row, compute distances.
pred_mat <- pred_summary %>% select(-country) %>% as.matrix()
rownames(pred_mat) <- pred_summary$country
pred_scaled <- scale(pred_mat)

# Germany's standardized predictor vector
germany_vec <- pred_scaled["West Germany", ]

# For each donor (non-Germany row), compute Euclidean distance to Germany
distances <- apply(pred_scaled[rownames(pred_scaled) != "West Germany", ], 1,
                   function(x) sqrt(sum((x - germany_vec)^2)))

data.frame(country = names(distances), distance = distances) %>%
  ggplot(aes(x = reorder(country, -distance), y = distance,
             fill = distance)) +
  geom_col() +
  scale_fill_gradient(low = "steelblue", high = "grey80") +
  coord_flip() +
  labs(title = "Euclidean Distance from West Germany in Predictor Space",
       subtitle = "Closer = more similar to Germany on predictor characteristics",
       x = NULL, y = "Distance (standardized predictors)") +
  theme_minimal() +
  theme(legend.position = "none")

# The distance plot gives an overall "how similar" score, but it's a single
# number per country — we can't see which predictors drive the difference.
# For that, compute % deviation from Germany for each predictor separately.
#   % difference = 100 * (country value - Germany value) / Germany value
# Germany sits at 0%, bars show how much higher/lower each country is.

# Pick a few countries to highlight (top donors + outliers)
highlight <- c("West Germany", "Austria", "Switzerland", "USA", "Japan", "Greece")

# Reshape: one row per country-predictor combination
pred_long <- pred_summary %>%
  filter(country %in% highlight) %>%
  pivot_longer(-country, names_to = "predictor", values_to = "value")

# Get Germany's value for each predictor as the reference point
germany_vals <- pred_long %>% filter(country == "West Germany") %>%
  select(predictor, germany_val = value)

# Compute % deviation from Germany for each country-predictor pair
pred_long %>%
  left_join(germany_vals, by = "predictor") %>%
  mutate(pct_diff = 100 * (value - germany_val) / germany_val) %>%
  ggplot(aes(x = pct_diff, y = country, fill = country == "West Germany")) +
  geom_col(show.legend = FALSE) +
  geom_vline(xintercept = 0, linewidth = 0.5) +
  scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "steelblue")) +
  facet_wrap(~ predictor, scales = "free_x", ncol = 3) +
  labs(title = "How Far Is Each Country from Germany on Each Predictor?",
       subtitle = "0% = identical to Germany. Bars = % deviation from Germany's value.",
       x = "% difference from Germany", y = NULL) +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"))

# From vectors to matrices:
# Germany's vector is X1 (6x1). Stack all 16 donors to get X0 (6x16).
# Goal: find weights W (16x1, non-negative, summing to 1) such that X0*W ≈ X1.
# i.e., find a weighted average of donor predictor vectors that approximates
# Germany's predictor vector.


# ==============================================================================
# 4. What dataprep() Produces: Four Matrices
# ==============================================================================
dataprep.out <- dataprep(
  foo = d,
  predictors = c("gdp", "tradeOpenness", "inflationRate"),
  dependent = "gdp",
  unit.variable = 1, time.variable = 3,
  special.predictors = list(
    list("industryShare",   1981:1990,    c("mean")),
    list("secondarySchool", c(1980, 1985), c("mean")),
    list("invest80",        1980,          c("mean"))
  ),
  treatment.identifier = 7,
  controls.identifier = unique(d$index)[-7],
  time.predictors.prior = 1981:1990,
  time.optimize.ssr = 1960:1989,
  unit.names.variable = 2,
  time.plot = 1960:2003
)

# Decoding the arguments:
#   unit.variable = 1      -> column position (column 1 = index)
#   time.variable = 3      -> column position (column 3 = year)
#   unit.names.variable = 2 -> column position (column 2 = country)
#   treatment.identifier = 7 -> data VALUE (West Germany has index = 7)
#   controls.identifier     -> data VALUES (all index values except 7)

# The four matrices (dataprep does NO optimization, just organizes data):
#   X1 (6x1):   Germany's predictor values, averaged over time.predictors.prior
#   X0 (6x16):  Each donor's predictor values, same averaging
#   Z1 (30x1):  Germany's GDP year-by-year over time.optimize.ssr
#   Z0 (30x16): Each donor's GDP year-by-year over same window
#
# Key difference: X matrices collapse time into ONE number per predictor.
# Z matrices keep the FULL time series of the outcome.
#   X0, X1 -> used in inner problem (match predictor profiles)
#   Z0, Z1 -> used in outer problem (evaluate outcome fit)

# Two-weighting intuition:
#   W (country weights): how much each donor contributes. Chosen to match
#     Germany's predictor profile (X0*W ≈ X1).
#   V (predictor importance): how much each predictor matters. Chosen so
#     the resulting W also tracks GDP year-by-year (Z0*W ≈ Z1).
#
# The optimization alternates:
#   1. Start with initial guess for V (e.g., uniform)
#   2. Inner step: given V, find best W — minimize weighted predictor
#      mismatch X1 - X0*W (convex combination of donors' predictors
#      matching Germany's predictors)
#   3. Evaluate: take W from step 2, check how well Z0*W tracks Z1
#      year-by-year (average squared gap across 30 pre-treatment years)
#   4. Outer step: adjust V to reduce the tracking error from step 3
#   5. Repeat 2-4 until tracking error stops improving

# Why different time windows?
#   time.predictors.prior = 1981:1990 — average predictors over this decade
#   time.optimize.ssr = 1960:1989     — evaluate GDP tracking over 30 years
# They serve fundamentally different roles.
#
# Why 1981-1990 for predictors? Authors did manual cross-validation:
# trained on 1971-80 predictor data, checked synthetic tracked GDP well
# in 1981-89. Then used 1981-1990 for final estimation (most recent data).

# Special predictors: custom averaging window per variable
#   industryShare over 1981-1990: annual data available
#   secondarySchool at 1980 & 1985: Barro-Lee quinquennial; 1990 contaminated
#   invest80 at 1980 only: quinquennial data

cat("X1 — Germany's predictor vector:\n")
print(dataprep.out$X1)

cat("\nX0 — Donor predictor matrix (first 3 countries):\n")
print(dataprep.out$X0[, 1:3])

cat("\nZ1 dims (outcome, pre-treatment):", dim(dataprep.out$Z1), "\n")
cat("Z0 dims (donor outcomes, pre-treatment):", dim(dataprep.out$Z0), "\n")


# ==============================================================================
# 5. The Nested Optimization
# ==============================================================================
# synth() performs a two-level nested optimization. The two levels use
# completely separate equations with different data.
#
# --- Inner problem: find W given V ---
# min_W (X1 - X0*W)' V (X1 - X0*W)   s.t. w_j >= 0, sum(w_j) = 1
#        (1x6)       (6x6)  (6x1)
#
# Uses X0 (6x16), X1 (6x1). Solved via constrained quadratic programming (QP).
# QPs have a globally optimal solution (no local minima) and are fast.
#
# V is a 6x6 DIAGONAL matrix. It sits inside a quadratic form.
# When you expand the multiplication:
#   = V1*(gdp diff)^2 + V2*(trade diff)^2 + V3*(inflation diff)^2 + ...
# V literally weights how much each predictor's mismatch matters.
# If V1 = 0.89 (GDP) and V2 = 0.001 (trade), the optimizer matches GDP
# hard and barely cares about trade.
#
# --- Outer problem: find the best V ---
# MSPE(V) = (1/T0) * sum_t (Z1_t - Z0_t * W*_V)^2
#                            (1x1)  (1x16) (16x1)
#
# W*_V = "the optimal W for this particular V" (from inner problem)
#
# Uses Z0 (30x16), Z1 (30x1). Solved via BFGS (gradient-based optimizer).
# BFGS perturbs V slightly, sees how tracking error changes, adjusts V.
# Not convex, so may find local minimum. Falls back to Nelder-Mead if noisy.
#
# MSPE = mean squared prediction error:
# (1/30) * sum_{t=1960}^{1989} (Germany GDP_t - Synthetic GDP_t)^2
#
# V does NOT appear in the MSPE equation. It enters indirectly:
# different V -> different W*_V -> different MSPE.
#
# Why V? Without it, all predictors weighted equally. GDP (thousands)
# dominates inflation (single digits). V lets the method learn which
# predictors matter for tracking the outcome.
#
# Matrix dimensions:
#   X1: 6x1    (Germany's 6 predictor averages)
#   X0: 6x16   (16 donors' predictor averages)
#   Z1: 30x1   (Germany's GDP, 1960-1989)
#   Z0: 30x16  (16 donors' GDP, 1960-1989)
#   V:  6x6    (diagonal, 6 free parameters)
#   W:  16x1   (country weights, must sum to 1)

synth.out <- synth(data.prep.obj = dataprep.out, method = "BFGS")
synth.tables <- synth.tab(dataprep.res = dataprep.out, synth.res = synth.out)


# ==============================================================================
# 6. Results
# ==============================================================================

# --- Understanding the output objects ---
cat("synth.out contains:\n")
print(names(synth.out))
cat("\nsynth.tables contains:\n")
print(names(synth.tables))

# synth.out$solution.w: W vector (16x1) — final country weights
# synth.out$solution.v: V diagonal (6x1) — predictor importance weights
# synth.out$loss.w:     inner loss (predictor mismatch) at solution
# synth.out$loss.v:     outer loss (MSPE) at solution
#
# synth.tab() convenience function:
#   tab.w:    country weights with names
#   tab.pred: predictor balance (treated vs synthetic vs donor average)
#   tab.v:    V weights

# --- Country weights: who contributes to Synthetic Germany? ---
w_df <- synth.tables$tab.w %>%
  as.data.frame() %>%
  mutate(label = paste0(unit.names, " (", unit.numbers, ")"))

ggplot(w_df, aes(x = reorder(label, w.weights), y = w.weights,
                 fill = w.weights > 0.05)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "steelblue", "FALSE" = "grey75")) +
  coord_flip() +
  labs(title = "Country Weights (W)",
       subtitle = "Synthetic Germany = weighted average of these donors",
       x = NULL, y = "Weight") +
  theme_minimal()

# --- Predictor balance: how close is the match? ---
# % difference between treated and synthetic
bal <- synth.tables$tab.pred[, 1:2]
bal_df <- data.frame(
  predictor = rownames(bal),
  treated = bal[, 1],
  synthetic = bal[, 2]
) %>%
  mutate(pct_diff = 100 * (synthetic - treated) / treated)

ggplot(bal_df, aes(x = reorder(predictor, abs(pct_diff)),
                   y = pct_diff, fill = pct_diff > 0)) +
  geom_col(show.legend = FALSE) +
  geom_hline(yintercept = 0) +
  scale_fill_manual(values = c("TRUE" = "steelblue", "FALSE" = "coral")) +
  coord_flip() +
  labs(title = "Predictor Balance: Synthetic vs Treated",
       subtitle = "% difference from Germany's actual value. Closer to 0 = better match.",
       x = NULL, y = "% difference") +
  theme_minimal()

kbl(bal, digits = 1, caption = "Predictor Balance Table") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)

# No formal test for balance — you eyeball it.
# Formal inference comes from placebo tests (Section 8).

# --- Predictor importance (V) ---
v_df <- data.frame(
  predictor = rownames(dataprep.out$X1),
  v_weight = round(as.numeric(synth.out$solution.v), 4)
)
kbl(v_df, caption = "Predictor Importance (V weights)") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)

# GDP dominates (V ≈ 0.89) because the outer loss is about tracking GDP.
# Matching GDP average is the most predictive feature of GDP trajectory.
# V was found by BFGS (or Nelder-Mead fallback). Since the outer problem
# isn't convex, different starting points could yield different V values.

# --- Experiment: What if V = (1, 0, 0, 0, 0, 0)? ---
# Why not just put all weight on GDP and ignore other predictors?
# We simulate this by running dataprep with only GDP as a predictor.
dataprep_gdp_only <- dataprep(
  foo = d,
  predictors = "gdp",
  dependent = "gdp",
  unit.variable = 1, time.variable = 3,
  treatment.identifier = 7,
  controls.identifier = unique(d$index)[-7],
  time.predictors.prior = 1981:1990,
  time.optimize.ssr = 1960:1989,
  unit.names.variable = 2,
  time.plot = 1960:2003
)
synth_gdp_only <- synth(data.prep.obj = dataprep_gdp_only, method = "BFGS")
synthetic_gdp_only <- dataprep_gdp_only$Y0plot %*% synth_gdp_only$solution.w

# Compare trajectories
synthetic_gdp <- dataprep.out$Y0plot %*% synth.out$solution.w

exp_df <- data.frame(
  year = rep(1960:2003, 3),
  gdp = c(as.numeric(dataprep.out$Y1plot),
          as.numeric(synthetic_gdp),
          as.numeric(synthetic_gdp_only)),
  type = rep(c("West Germany (actual)",
               "Synthetic (optimized V)",
               "Synthetic (GDP-only V)"), each = 44)
)

ggplot(exp_df, aes(x = year, y = gdp, color = type, linetype = type)) +
  geom_line(linewidth = 1.1) +
  geom_vline(xintercept = 1990, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("West Germany (actual)" = "red",
                                "Synthetic (optimized V)" = "steelblue",
                                "Synthetic (GDP-only V)" = "orange")) +
  scale_linetype_manual(values = c("West Germany (actual)" = "solid",
                                   "Synthetic (optimized V)" = "solid",
                                   "Synthetic (GDP-only V)" = "dashed")) +
  labs(title = "Does Optimizing V Actually Matter?",
       subtitle = "GDP-only V vs full optimized V — compare pre-treatment tracking",
       x = "Year", y = "GDP per capita (PPP, 2002 USD)",
       color = NULL, linetype = NULL) +
  theme_minimal() +
  theme(legend.position = "bottom")

# Compare MSPE and country weights
pre_years <- 1:30  # 1960-1989
mspe_optimized <- mean((as.numeric(dataprep.out$Y1plot[pre_years, ]) -
                         as.numeric(synthetic_gdp[pre_years, ]))^2)
mspe_gdp_only  <- mean((as.numeric(dataprep_gdp_only$Y1plot[pre_years, ]) -
                         as.numeric(synthetic_gdp_only[pre_years, ]))^2)

cat("Pre-treatment MSPE (optimized V):", round(mspe_optimized, 1), "\n")
cat("Pre-treatment MSPE (GDP-only V): ", round(mspe_gdp_only, 1), "\n")
cat("Ratio (GDP-only / optimized):    ", round(mspe_gdp_only / mspe_optimized, 2), "\n")

# Compare country weights: GDP-only vs optimized V
country_lookup <- synth.tables$tab.w %>% as.data.frame()
w_compare <- data.frame(
  country = country_lookup$unit.names,
  w_optimized = round(as.numeric(synth.out$solution.w), 3),
  w_gdp_only  = round(as.numeric(synth_gdp_only$solution.w), 3)
) %>%
  filter(w_optimized > 0.01 | w_gdp_only > 0.01) %>%
  arrange(desc(w_optimized))

cat("\nCountry weights comparison (optimized V vs GDP-only):\n")
print(w_compare)

# Optimized V achieves lower MSPE because other predictors carry info about
# structural similarity that GDP averages alone miss. The remaining ~11%
# weight on trade, inflation, industry, schooling, and investment helps
# pick a more structurally similar blend of donors.


# ==============================================================================
# 7. The Treatment Effect
# ==============================================================================
# V was a tool for finding W. Now that we have W, we apply it directly to
# the outcome data. V doesn't appear in any final calculation.

# Y1plot (44x1): treated outcome over full plot range (1960-2003)
# Y0plot (44x16): donor outcomes over full plot range
# These are distinct from Z1/Z0 which only cover the optimization window
# (1960-1989). Z matrices were used to FIND W; Y matrices APPLY W.

# %*% = matrix multiplication: (44x16) x (16x1) = (44x1)
synthetic_gdp <- dataprep.out$Y0plot %*% synth.out$solution.w

gaps <- dataprep.out$Y1plot - synthetic_gdp
gaps_df <- data.frame(
  year = as.numeric(rownames(gaps)),
  gap  = as.numeric(gaps)
)

# --- Actual vs Synthetic GDP ---
plot_df <- data.frame(
  year = rep(1960:2003, 2),
  gdp  = c(as.numeric(dataprep.out$Y1plot), as.numeric(synthetic_gdp)),
  type = rep(c("West Germany", "Synthetic"), each = 44)
)

ggplot(plot_df, aes(x = year, y = gdp, color = type, linetype = type)) +
  geom_line(linewidth = 1.1) +
  geom_vline(xintercept = 1990, linetype = "dashed", color = "grey40") +
  annotate("text", x = 1991, y = max(plot_df$gdp) * 0.6, label = "Reunification",
           hjust = 0, fontface = "italic", color = "grey40") +
  scale_color_manual(values = c("Synthetic" = "steelblue", "West Germany" = "red")) +
  labs(title = "Actual vs Synthetic West Germany",
       x = "Year", y = "GDP per capita (PPP, 2002 USD)", color = NULL, linetype = NULL) +
  theme_minimal() +
  theme(legend.position = "bottom")

# --- The Gap = The Treatment Effect ---
# Unlike DiD (single beta), SCM gives a treatment effect for every
# post-treatment year: tau_t = Y1_t - sum_j(w_j * Y0j_t)

ggplot(gaps_df, aes(x = year, y = gap)) +
  geom_area(data = filter(gaps_df, year >= 1990), fill = "red", alpha = 0.15) +
  geom_line(linewidth = 1, color = "darkred") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 1990, linetype = "dashed", color = "grey40") +
  labs(title = "Estimated Effect of Reunification on West German GDP",
       subtitle = "Shaded area = cost of reunification",
       x = "Year", y = "GDP Gap (per capita, USD)") +
  theme_minimal()

post_gaps <- filter(gaps_df, year >= 1990)
pre_gdp_avg <- mean(as.numeric(
  dataprep.out$Y1plot[as.numeric(rownames(dataprep.out$Y1plot)) < 1990, ]))

cat("Average post-treatment gap:", round(mean(post_gaps$gap), 1), "USD per capita\n")
cat("Gap in 2003 (end of sample):", round(post_gaps$gap[post_gaps$year == 2003], 1),
    "USD per capita\n")
cat("Average gap as % of pre-treatment GDP:",
    round(100 * mean(post_gaps$gap) / pre_gdp_avg, 1), "%\n")


# ==============================================================================
# 8. Optional: Placebo Studies
# ==============================================================================
# SCM has no standard errors or p-values. Abadie et al. (2015) use two types
# of placebo studies to evaluate credibility. The logic: if our method produces
# a large effect estimate even when there is no real treatment, we shouldn't
# trust it.

# --- Placebo 1: In-time placebo (reassign treatment to 1975) ---
# What if we pretend reunification happened in 1975? Rerun with 1975 as
# treatment year, lagging predictor windows accordingly. If the synthetic
# has predictive power, we should see good fit 1960-1975 and NO divergence
# 1975-1990 (nothing actually happened in 1975).

dataprep_1975 <- dataprep(
  foo = d,
  predictors = c("gdp", "tradeOpenness", "inflationRate"),
  dependent = "gdp",
  unit.variable = 1, time.variable = 3,
  special.predictors = list(
    list("industryShare",   1971:1975,    c("mean")),
    list("secondarySchool", c(1965, 1970), c("mean")),
    list("invest80",        1980,          c("mean"))
  ),
  treatment.identifier = 7,
  controls.identifier = unique(d$index)[-7],
  time.predictors.prior = 1966:1975,
  time.optimize.ssr = 1960:1974,
  unit.names.variable = 2,
  time.plot = 1960:1990
)
synth_1975 <- synth(data.prep.obj = dataprep_1975, method = "BFGS")

synthetic_gdp_1975 <- dataprep_1975$Y0plot %*% synth_1975$solution.w

intime_df <- data.frame(
  year = rep(1960:1990, 2),
  gdp  = c(as.numeric(dataprep_1975$Y1plot),
           as.numeric(synthetic_gdp_1975)),
  type = rep(c("West Germany", "Synthetic (placebo 1975)"), each = 31)
)

ggplot(intime_df, aes(x = year, y = gdp, color = type, linetype = type)) +
  geom_line(linewidth = 1.1) +
  geom_vline(xintercept = 1975, linetype = "dashed", color = "grey40") +
  annotate("text", x = 1976, y = min(intime_df$gdp) * 1.05,
           label = "Placebo\nreunification", hjust = 0, fontface = "italic",
           color = "grey40", size = 3.5) +
  scale_color_manual(values = c("Synthetic (placebo 1975)" = "steelblue",
                                "West Germany" = "red")) +
  labs(title = "In-Time Placebo: Fake Reunification in 1975",
       x = "Year", y = "GDP per capita (PPP, 2002 USD)",
       color = NULL, linetype = NULL) +
  theme_minimal() +
  theme(legend.position = "bottom")

# Log the gap values
actual_1975 <- as.numeric(dataprep_1975$Y1plot)
synth_1975_vals <- as.numeric(synthetic_gdp_1975)
gap_1975 <- actual_1975 - synth_1975_vals
years_1975 <- 1960:1990

cat("Pre-1975 avg gap:", round(mean(gap_1975[1:15]), 1), "\n")
cat("Post-1975 avg gap:", round(mean(gap_1975[16:31]), 1), "\n")
cat("Gap in 1980:", round(gap_1975[years_1975 == 1980], 1), "\n")
cat("Gap in 1985:", round(gap_1975[years_1975 == 1985], 1), "\n")
cat("Gap in 1990:", round(gap_1975[years_1975 == 1990], 1), "\n")

# The synthetic tracks reasonably well 1960-1975 (pre-placebo gaps ±70 USD),
# but after 1975 the trajectories diverge: the synthetic undershoots actual
# West Germany, with the gap growing to over 2000 USD by 1990.
#
# What does this tell us? The in-time placebo doesn't pass cleanly. The model
# trained on only 15 years (1960-1974) doesn't have enough information to
# track Germany out of sample. Compare to the main model: 30 years for the
# optimization window — twice the data — much tighter pre-treatment fit.
#
# Important lesson: the training window matters. With a short window, the
# synthetic drifts. With a longer window, it locks on. The paper reports a
# clean in-time placebo (Figure 4), likely because they tuned the predictor
# windows more carefully. The choice of training window shapes the story —
# this is a researcher degree of freedom you should be aware of.

# --- Placebo 2: In-space placebos (reassign treatment to other countries) ---
# Reassign treatment to each donor country. Run the exact same SCM pretending
# each donor was "treated" in 1990. This gives a distribution of placebo
# effects. If Germany's effect is unusually large relative to this
# distribution, we take it as evidence the effect is real.

all_gaps <- list()
donor_ids <- unique(d$index)[unique(d$index) != 7]
country_names <- d %>% distinct(index, country) %>% deframe()

for (id in donor_ids) {
  tryCatch({
    dp <- dataprep(
      foo = d,
      predictors = c("gdp", "tradeOpenness", "inflationRate"),
      dependent = "gdp",
      unit.variable = 1, time.variable = 3,
      special.predictors = list(
        list("industryShare",   1981:1990,    c("mean")),
        list("secondarySchool", c(1980, 1985), c("mean")),
        list("invest80",        1980,          c("mean"))
      ),
      treatment.identifier = id,
      controls.identifier = setdiff(unique(d$index), c(id, 7)),
      time.predictors.prior = 1981:1990,
      time.optimize.ssr = 1960:1989,
      unit.names.variable = 2,
      time.plot = 1960:2003
    )
    so <- synth(data.prep.obj = dp, method = "BFGS")
    g <- as.numeric(dp$Y1plot - (dp$Y0plot %*% so$solution.w))
    all_gaps[[country_names[as.character(id)]]] <- g
  }, error = function(e) {
    cat("Skipping", country_names[as.character(id)], ":", e$message, "\n")
  })
}

# Add Germany's actual gap
all_gaps[["West Germany"]] <- as.numeric(gaps)

# Gap plot: all placebos in grey, Germany in red
placebo_df <- bind_rows(
  lapply(names(all_gaps), function(nm) {
    data.frame(country = nm, year = 1960:2003, gap = all_gaps[[nm]])
  })
)

ggplot(placebo_df, aes(x = year, y = gap, group = country)) +
  geom_line(data = filter(placebo_df, country != "West Germany"),
            color = "grey75", alpha = 0.5) +
  geom_line(data = filter(placebo_df, country == "West Germany"),
            color = "red", linewidth = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 1990, linetype = "dashed", color = "grey40") +
  labs(title = "In-Space Placebo: Germany (Red) vs All Donor Countries (Grey)",
       x = "Year", y = "GDP Gap (per capita)") +
  theme_minimal()

# Some placebos show large gaps, but that alone doesn't mean much. A large
# post-1990 gap is uninformative if the synthetic couldn't track the country
# well even before 1990. Abadie et al. compute the RMSPE ratio.
#
# RMSPE = sqrt( (1/T) * sum(gap_t^2) )
#
# By taking RMSPE_post / RMSPE_pre, we avoid discarding countries with poor
# pre-treatment fit. A country with large post AND pre gap gets a modest
# ratio. Germany (large post, small pre) gets a high ratio.

# Diagnostics table
gap_diagnostics <- data.frame(
  country = names(all_gaps),
  pre_rmspe  = sapply(all_gaps, function(g) sqrt(mean(g[1:30]^2))),
  post_rmspe = sapply(all_gaps, function(g) sqrt(mean(g[31:44]^2))),
  avg_post_gap = sapply(all_gaps, function(g) mean(g[31:44]))
) %>%
  mutate(is_germany = country == "West Germany") %>%
  arrange(avg_post_gap)

kbl(gap_diagnostics %>% select(-is_germany),
    digits = 1,
    col.names = c("Country", "Pre-RMSPE", "Post-RMSPE", "Avg Post-1990 Gap"),
    caption = "Placebo diagnostics for each country") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE) %>%
  row_spec(which(gap_diagnostics$is_germany), bold = TRUE, color = "red")

# RMSPE ratio plot (cf. Figure 5 in Abadie et al. 2015)
rmspe_df <- data.frame(
  country = names(all_gaps),
  pre_rmspe = sapply(all_gaps, function(g) sqrt(mean(g[1:30]^2))),
  post_rmspe = sapply(all_gaps, function(g) sqrt(mean(g[31:44]^2)))
) %>%
  mutate(ratio = post_rmspe / pre_rmspe,
         is_germany = country == "West Germany") %>%
  arrange(desc(ratio))

ggplot(rmspe_df, aes(x = reorder(country, ratio), y = ratio, fill = is_germany)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "grey75")) +
  coord_flip() +
  labs(title = "Ratio of Post-Reunification RMSPE to Pre-Reunification RMSPE",
       subtitle = "West Germany and control countries (cf. Figure 5 in Abadie et al. 2015)",
       x = NULL, y = "Post-period RMSPE / Pre-period RMSPE") +
  theme_minimal()

germany_rank <- which(rmspe_df$country == "West Germany")
p_value <- germany_rank / nrow(rmspe_df)
cat("Germany's RMSPE ratio rank:", germany_rank, "out of", nrow(rmspe_df), "\n")
cat("Pseudo p-value:", round(p_value, 4), "\n")

# West Germany has the highest RMSPE ratio: the post-reunification gap is
# about 16 times larger than the pre-reunification gap. If one were to pick
# a country at random, the probability of obtaining a ratio as large as
# West Germany's is 1/17 ≈ 0.059.
