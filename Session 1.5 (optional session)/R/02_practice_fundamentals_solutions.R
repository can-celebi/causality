# ==============================================================================
# PRACTICE: FUNDAMENTAL R SKILLS FOR CAUSAL INFERENCE
# Progressive exercises using simulated datasets x, y, z
# ==============================================================================

# First, load the datasets from the previous script
source("01_data_generation.R")

library(tidyverse)
library(ggplot2)

# ==============================================================================
# PART 1: SUBSETTING & FILTERING (Using dataset x - Fork example)
# ==============================================================================

cat("\n\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")
cat("PART 1: SUBSETTING & FILTERING (Dataset x)\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")

# ===== 1.1: Accessing columns =====
cat("\n[1.1] Accessing columns:\n")
cat("Using $: x$gender (shows all values in gender column)\n")
print(head(x$gender))

cat("\nUsing []: x[, 'gender'] (alternative syntax)\n")
print(head(x[, "gender"]))

# ===== 1.2: Logical filtering with conditions =====
cat("\n\n[1.2] Logical filtering - Get health scores for high-income people only:\n")

# Base R approach 1: Index with logical condition
high_income_health_v1 <- x$health_score[x$income_level == "high"]
cat("Using x$health_score[x$income_level == 'high']:\n")
print(head(high_income_health_v1))

# Base R approach 2: Subset entire rows
high_income_full_v2 <- x[x$income_level == "high", ]
cat("\nUsing x[x$income_level == 'high', ] - Full dataset for high income:\n")
print(head(high_income_full_v2))

# Tidyverse alternative
high_income_tidy <- x %>%
  filter(income_level == "high")
cat("\nTidyverse: filter(x, income_level == 'high')\n")
cat("Result has", nrow(high_income_tidy), "rows\n")

# ===== 1.3: Subsetting with multiple conditions =====
cat("\n\n[1.3] Multiple conditions with & (AND) and | (OR):\n")

# AND: Both conditions must be true
cat("\nAND: High income AND high education (>16 years):\n")
complex_filter_and <- x[x$income_level == "high" & x$education_years > 16, ]
cat("Result has", nrow(complex_filter_and), "rows\n")
print(head(complex_filter_and))

# OR: At least one condition is true
cat("\nOR: Low income OR young age (<25):\n")
complex_filter_or <- x[x$income_level == "low" | x$age < 25, ]
cat("Result has", nrow(complex_filter_or), "rows\n")

# NOT: Opposite of a condition
cat("\nNOT: Not low income (mid or high):\n")
not_low_income <- x[x$income_level != "low", ]
cat("Result has", nrow(not_low_income), "rows\n")

# ===== 1.4: Creating new subset dataframes =====
cat("\n\n[1.4] Creating and storing subset dataframes:\n")

high_ed <- x[x$education_years > 16, ]
mid_ed <- x[x$education_years >= 12 & x$education_years <= 16, ]
low_ed <- x[x$education_years < 12, ]

cat("High education group:", nrow(high_ed), "people\n")
cat("Mid education group:", nrow(mid_ed), "people\n")
cat("Low education group:", nrow(low_ed), "people\n")

# ===== 1.5: Using ifelse() for conditional operations =====
cat("\n\n[1.5] Creating new variables with ifelse():\n")
cat("ifelse(condition, value_if_true, value_if_false)\n\n")

# Example: Create a health category based on health score
x$health_category <- ifelse(
  x$health_score >= 70, "Excellent",
  ifelse(x$health_score >= 50, "Good", "Poor")
)

cat("New variable 'health_category' created:\n")
print(table(x$health_category))

# Example: Binary indicator for high earners
x$high_earner <- ifelse(x$income_level == "high", 1, 0)
cat("\nBinary variable 'high_earner' created:\n")
print(table(x$high_earner))

# ===== 1.6: Tidyverse alternatives =====
cat("\n\n[1.6] Tidyverse alternatives for subsetting:\n")

# filter() for subsetting rows
x_filtered <- x %>%
  filter(income_level == "high", education_years > 15)

# select() for choosing columns
x_selected <- x %>%
  select(id, gender, education_years, income_numeric, health_score)

# mutate() for creating new variables
x_mutated <- x %>%
  mutate(
    health_category = ifelse(health_score >= 70, "Excellent", "Good"),
    log_income = log(income_numeric)
  )

cat("After mutate(), x now has", ncol(x_mutated), "columns\n")
cat("New columns added: health_category, log_income\n")


# ==============================================================================
# PART 2: SUMMARY STATISTICS & GROUP-WISE OPERATIONS (Dataset y - Chain example)
# ==============================================================================

cat("\n\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")
cat("PART 2: SUMMARY STATISTICS (Dataset y - Chain example)\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")

# ===== 2.1: Basic statistics =====
cat("\n[2.1] Basic statistics on fitness scores:\n")
cat("Mean fitness:", round(mean(y$fitness_score), 2), "\n")
cat("Median fitness:", round(median(y$fitness_score), 2), "\n")
cat("SD fitness:", round(sd(y$fitness_score), 2), "\n")
cat("Min-Max:", round(min(y$fitness_score), 2), "-", round(max(y$fitness_score), 2), "\n")

# ===== 2.2: Subset approach for group comparisons =====
cat("\n\n[2.2] Comparing fitness by exercise level (subset approach):\n")

# Create exercise groups
low_exercise <- y[y$exercise_hours < 3, ]
high_exercise <- y[y$exercise_hours >= 3, ]

cat("Low exercisers (< 3 hrs/week):\n")
cat("  Mean fitness:", round(mean(low_exercise$fitness_score), 2), "\n")
cat("  N:", nrow(low_exercise), "\n")

cat("\nHigh exercisers (>= 3 hrs/week):\n")
cat("  Mean fitness:", round(mean(high_exercise$fitness_score), 2), "\n")
cat("  N:", nrow(high_exercise), "\n")

cat("\nDifference:", round(mean(high_exercise$fitness_score) - mean(low_exercise$fitness_score), 2), "\n")

# ===== 2.3: Creating multiple group summaries =====
cat("\n\n[2.3] Comparing satisfaction by multiple groups:\n")

# Split by education level
edu_groups <- split(y, y$education_years > 14)
cat("Satisfaction by education level:\n")
cat("Lower education (<= 14 years):\n")
cat("  Mean satisfaction:", round(mean(edu_groups$"FALSE"$life_satisfaction), 2), "\n")
cat("Higher education (> 14 years):\n")
cat("  Mean satisfaction:", round(mean(edu_groups$"TRUE"$life_satisfaction), 2), "\n")

# ===== 2.4: Summary tables with Tidyverse =====
cat("\n\n[2.4] Creating summary tables with tidyverse:\n")

summary_by_exercise <- y %>%
  mutate(exercise_group = ifelse(exercise_hours < 3, "Low", "High")) %>%
  group_by(exercise_group) %>%
  summarize(
    n = n(),
    mean_fitness = mean(fitness_score),
    sd_fitness = sd(fitness_score),
    mean_satisfaction = mean(life_satisfaction),
    .groups = 'drop'
  )

cat("Summary by exercise level:\n")
print(summary_by_exercise)

# ===== 2.5: Creating new variables =====
cat("\n\n[2.5] Creating new variables through arithmetic:\n")

y$fitness_deviation <- y$fitness_score - mean(y$fitness_score)
y$exercise_category <- cut(
  y$exercise_hours,
  breaks = c(0, 2, 4, 6, 10),
  labels = c("Sedentary", "Moderate", "Active", "Very Active")
)

cat("New variables created:\n")
cat("  fitness_deviation: deviation from mean\n")
cat("  exercise_category: categorical grouping\n")
print(table(y$exercise_category))


# ==============================================================================
# PART 3: VISUALIZATION WITH GGPLOT2 (All datasets)
# ==============================================================================

cat("\n\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")
cat("PART 3: VISUALIZATION WITH GGPLOT2\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")

# ===== 3.1: Boxplot (Dataset x - Fork) =====
cat("\n[3.1] Boxplot: Health scores by income level (Dataset x)\n")

plot_x_box <- ggplot(x, aes(x = income_level, y = health_score, fill = income_level)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3) +  # Add individual points
  labs(
    title = "Health Score by Income Level",
    subtitle = "Fork structure: Education causes both income and health",
    x = "Income Level",
    y = "Health Score",
    fill = "Income Level"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

print(plot_x_box)

# ===== 3.2: Scatter plot with regression line (Dataset y - Chain) =====
cat("\n\n[3.2] Scatter plot: Exercise vs Life Satisfaction (Dataset y)\n")

plot_y_scatter <- ggplot(y, aes(x = exercise_hours, y = life_satisfaction)) +
  geom_point(aes(color = fitness_score), alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "darkblue") +
  scale_color_gradient(low = "lightblue", high = "darkblue") +
  labs(
    title = "Exercise and Life Satisfaction",
    subtitle = "Chain structure: Exercise → Fitness → Satisfaction",
    x = "Exercise Hours per Week",
    y = "Life Satisfaction Score",
    color = "Fitness Score"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(plot_y_scatter)

# ===== 3.3: Scatter plot colored by group (Dataset z - Collider) =====
cat("\n\n[3.3] Scatter plot: Skills by job offer status (Dataset z)\n")

plot_z_scatter <- ggplot(z, aes(x = programming_score, y = communication_score,
                                 color = factor(got_job_offer), shape = factor(got_job_offer))) +
  geom_point(size = 2, alpha = 0.6) +
  scale_color_manual(values = c("0" = "lightcoral", "1" = "darkgreen"),
                     labels = c("0" = "No Job Offer", "1" = "Got Job Offer")) +
  scale_shape_manual(values = c("0" = 1, "1" = 16),
                     labels = c("0" = "No Job Offer", "1" = "Got Job Offer")) +
  labs(
    title = "Programming vs Communication Skills",
    subtitle = "Collider structure: Both skills → Job Offer (conditioning creates bias)",
    x = "Programming Skill Score",
    y = "Communication Skill Score",
    color = "Job Offer Status",
    shape = "Job Offer Status"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(plot_z_scatter)

# ===== 3.4: Faceted plots for subgroups =====
cat("\n\n[3.4] Faceted plot: Health by income, separate by gender (Dataset x)\n")

plot_x_facet <- ggplot(x, aes(x = income_level, y = health_score, fill = gender)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ gender) +
  labs(
    title = "Health Scores by Income and Gender",
    x = "Income Level",
    y = "Health Score",
    fill = "Gender"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45)
  )

print(plot_x_facet)


# ==============================================================================
# PART 4: BASIC REGRESSION & DEMONSTRATING BIAS (All datasets)
# ==============================================================================

cat("\n\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")
cat("PART 4: REGRESSION & CAUSAL INFERENCE\n")
cat("=" %+% paste(rep("=", 76), collapse = ""), "\n")

# ===== 4.1: Fork example (Dataset x) =====
cat("\n[4.1] FORK STRUCTURE (Dataset x): Income → Health relationship\n")
cat("Question: Does higher income improve health?\n\n")

# Wrong specification: Without controlling for education
model_x1 <- lm(health_score ~ income_numeric, data = x)
cat("WRONG MODEL: health ~ income (ignoring education)\n")
cat("Coefficient on income:", round(coef(model_x1)["income_numeric"], 8), "\n")
cat("Interpretation: $1000 more income → ", round(coef(model_x1)["income_numeric"] * 1000, 2),
    " points health\n")
cat("(This is BIASED due to confounding!)\n\n")

# Correct specification: Controlling for education
model_x2 <- lm(health_score ~ income_numeric + education_years, data = x)
cat("CORRECT MODEL: health ~ income + education\n")
cat("Coefficient on income:", round(coef(model_x2)["income_numeric"], 8), "\n")
cat("Coefficient on education:", round(coef(model_x2)["education_years"], 4), "\n")
cat("Interpretation: After controlling for education,\n")
cat("                income has NO effect on health (as expected)\n")
cat("                but education DOES (education was the confounder)\n\n")

cat("LESSON: Failing to control for the confounder (education) gives biased results\n")

# ===== 4.2: Chain example (Dataset y) =====
cat("\n\n[4.2] CHAIN STRUCTURE (Dataset y): Exercise → Fitness → Satisfaction\n")
cat("Question: Does exercise improve life satisfaction?\n\n")

# Correct specification: Without controlling for fitness (get total effect)
model_y1 <- lm(life_satisfaction ~ exercise_hours, data = y)
cat("CORRECT MODEL: satisfaction ~ exercise (to measure total effect)\n")
cat("Coefficient on exercise:", round(coef(model_y1)["exercise_hours"], 4), "\n")
cat("Interpretation: 1 more hour of exercise per week → ",
    round(coef(model_y1)["exercise_hours"], 2), " points satisfaction\n")
cat("(This captures the TOTAL effect: exercise → fitness → satisfaction)\n\n")

# Wrong specification: Controlling for fitness (blocks the pathway)
model_y2 <- lm(life_satisfaction ~ exercise_hours + fitness_score, data = y)
cat("WRONG MODEL (for total effect): satisfaction ~ exercise + fitness\n")
cat("Coefficient on exercise:", round(coef(model_y2)["exercise_hours"], 4), "\n")
cat("Interpretation: When we also control for fitness,\n")
cat("                the exercise effect disappears!\n")
cat("(We blocked the mechanism by controlling for the mediator)\n\n")

cat("LESSON: Controlling for the mediator kills the effect!\n")

# ===== 4.3: Collider example (Dataset z) =====
cat("\n\n[4.3] COLLIDER STRUCTURE (Dataset z): Programming & Communication → Job Offer\n")
cat("Question: Are programming and communication skills correlated?\n\n")

# Correct specification: Full population
cat("CORRECT: In the full population\n")
cor_full <- cor(z$programming_score, z$communication_score)
cat("Correlation:", round(cor_full, 3), "\n")
cat("(They are independent - no relationship)\n\n")

# Wrong specification: Only among those with job offers (conditioning on collider)
z_hired <- z[z$got_job_offer == 1, ]
cor_hired <- cor(z_hired$programming_score, z_hired$communication_score)
cat("WRONG: Among job offer recipients only\n")
cat("Correlation:", round(cor_hired, 3), "\n")

model_z <- lm(communication_score ~ programming_score, data = z_hired)
cat("Regression coefficient:", round(coef(model_z)["programming_score"], 4), "\n")
cat("(We created a spurious negative relationship!)\n\n")

cat("LESSON: Conditioning on the collider creates spurious correlation\n")

# ===== 4.4: Comparing specifications side-by-side =====
cat("\n\n[4.4] Summary: How coefficient estimates change\n\n")

results_summary <- data.frame(
  Structure = c("Fork", "Chain", "Collider"),
  Without_Control = c(
    round(coef(model_x1)["income_numeric"], 6),
    round(coef(model_y1)["exercise_hours"], 4),
    round(cor_full, 3)
  ),
  With_Control = c(
    round(coef(model_x2)["income_numeric"], 6),
    round(coef(model_y2)["exercise_hours"], 4),
    round(cor_hired, 3)
  ),
  Interpretation = c(
    "Bias in one, Unbiased in other (control!)",
    "Total effect in one, Direct effect in other (don't control!)",
    "Real in one, Spurious in other (don't condition!)"
  )
)

print(results_summary)

cat("\n" %+% paste(rep("=", 76), collapse = ""))
cat("\nEnd of Practice Exercises\n\n")
