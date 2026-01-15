# ==============================================================================
# DATA GENERATION FOR CAUSAL INFERENCE EXAMPLES
# Three realistic datasets with demographics
# ==============================================================================

library(tidyverse)

set.seed(42)

# ==============================================================================
# COMMON DEMOGRAPHICS (for all three datasets)
# ==============================================================================

n <- 250  # Sample size for each dataset

# Generate common demographic variables
gender <- sample(c("Male", "Female"), size = n, replace = TRUE, prob = c(0.55, 0.45))
age <- rnorm(n, mean = 35, sd = 10)
age <- round(age)
age <- pmax(age, 18)  # if any value less than 18 replaces it with 18

education_years <- rnorm(n, mean = 14, sd = 3)
education_years <- round(education_years)

# ==============================================================================
# DATASET X: FORK / CONFOUNDER STRUCTURE
# ==============================================================================
# Story: Education affects both income AND health
# Structure: education_years → income_level AND education_years → health_score
# Why it matters: If we look at income → health without controlling for education,
#                 we get biased results
#
# Key lesson: MUST control for the confounder (education)

# DATASET X: FORK / CONFOUNDER STRUCTURE
# Education is the common cause that affects both income and health
# education_years → income_numeric AND education_years → health_score

# Generate income and health based on education (the common cause)
# Both are affected by education, creating the fork structure
income_numeric <- round(20000 + 3000 * education_years + rnorm(n, mean = 0, sd = 8000))

health_score <- 40 + 2.5 * education_years + rnorm(n, mean = 0, sd = 5)

# Assemble dataset x
x <- data.frame(
  id = 1:n,
  gender = gender,
  age = age,
  education_years = education_years,
  income_numeric = income_numeric,
  health_score = health_score
)

cat("Dataset x created with", nrow(x), "observations\n\n")
print(head(x))
cat("\nDescriptive statistics:\n")
print(summary(x))

# Demonstrate confounding
# Demonstrate confounding: does income really affect health?
# Without controlling for education, there's a spurious correlation
model_x_wrong <- lm(health_score ~ income_numeric, data = x)
cat("Effect of income on health:", round(coef(model_x_wrong)["income_numeric"], 8), "\n")
cat("(Spurious! Income doesn't really affect health; education does.)\n")

# Now control for education
model_x_correct <- lm(health_score ~ income_numeric + education_years, data = x)
cat("Effect of income on health:", round(coef(model_x_correct)["income_numeric"], 8), "\n")
cat("(No effect! The confounding path is blocked.)\n")


# ==============================================================================
# DATASET Y: CHAIN / MEDIATOR STRUCTURE
# ==============================================================================
# Story: Exercise habits → Fitness level → Life satisfaction
# Structure: exercise_hours → fitness_score → life_satisfaction
# Why it matters: If we control for fitness when examining exercise → satisfaction,
#                 we block the causal path
#
# Key lesson: Do NOT control for the mediator (fitness)

# DATASET Y: CHAIN / MEDIATOR STRUCTURE
# Exercise affects fitness, and fitness affects life satisfaction
# exercise_hours → fitness_score → life_satisfaction

# Generate exercise hours (exogenous variable)
exercise_hours <- rnorm(n, mean = 4, sd = 2)

# Generate fitness based on exercise (the mediator)
# fitness = f(exercise_hours, noise)
fitness_score <- 40 + 3 * exercise_hours + rnorm(n, mean = 0, sd = 6)

# Generate life satisfaction based on fitness (the outcome)
# satisfaction = f(fitness_score, noise)
life_satisfaction <- 50 + 0.8 * fitness_score + rnorm(n, mean = 0, sd = 8)

# Assemble dataset y
y <- data.frame(
  id = 1:n,
  gender = gender,
  age = age,
  education_years = education_years,
  exercise_hours = exercise_hours,
  fitness_score = fitness_score,
  life_satisfaction = life_satisfaction
)

cat("Dataset y created with", nrow(y), "observations\n\n")
print(head(y))
cat("\nDescriptive statistics:\n")
print(summary(y))

# Demonstrate mediation: does exercise really improve satisfaction?
# Without controlling for fitness, we see the total effect
model_y_correct <- lm(life_satisfaction ~ exercise_hours, data = y)
cat("Effect of exercise on satisfaction:", round(coef(model_y_correct)["exercise_hours"], 4), "\n")
cat("(Total effect: Exercise improves satisfaction via fitness improvement)\n")

# Now control for fitness - this blocks the causal mechanism
model_y_wrong <- lm(life_satisfaction ~ exercise_hours + fitness_score, data = y)
cat("Effect of exercise on satisfaction:", round(coef(model_y_wrong)["exercise_hours"], 4), "\n")
cat("(Effect disappears! We blocked the mechanism by controlling for fitness.)\n")


# ==============================================================================
# DATASET Z: COLLIDER STRUCTURE
# ==============================================================================
# Story: Programming skill → Job offer ← Communication skill
# Structure: programming_score → got_job_offer ← communication_score
# Why it matters: Programming and communication are independent,
#                 but among those with job offers, they appear correlated
#
# Key lesson: Do NOT control for the collider (job offer)

# DATASET Z: COLLIDER STRUCTURE
# Both programming and communication skills independently affect job offers
# programming_score → got_job_offer ← communication_score

# Generate programming and communication skills (exogenous, independent)
programming_score <- rnorm(n, mean = 50, sd = 15)
communication_score <- rnorm(n, mean = 50, sd = 15)

# Check if skills are correlated in the full population
cor_overall <- cor(programming_score, communication_score)
cat("Full population - Correlation:", round(cor_overall, 3), "\n")

# Generate job offer based on both skills
# You get hired if: programming_score + communication_score > 100
got_job_offer <- (programming_score + communication_score > 100) * 1

# Assemble dataset z
z <- data.frame(
  id = 1:n,
  gender = gender,
  age = age,
  education_years = education_years,
  programming_score = programming_score,
  communication_score = communication_score,
  got_job_offer = got_job_offer
)

cat("Dataset z created with", nrow(z), "observations\n\n")
print(head(z))
cat("\nDescriptive statistics:\n")
print(summary(z))

# Demonstrate collider bias: what happens when we filter by job offer?
cat("\nAmong job offer recipients:\n")
z_hired <- z[z$got_job_offer == 1, ]
cor_hired <- cor(z_hired$programming_score, z_hired$communication_score)
cat("Correlation:", round(cor_hired, 3), "\n")
cat("Spurious negative correlation! Collider bias in action.\n")
cat("Why? Low programming + hired = compensated by high communication.\n")

# Regression among hired
model_z <- lm(communication_score ~ programming_score, data = z_hired)
cat("\nRegression coefficient:", round(coef(model_z)["programming_score"], 4), "\n")


# ==============================================================================
# SAVE THE DATASETS
# ==============================================================================

cat("\nSUMMARY: Three causal structures demonstrated\n")
cat("x  - Fork/Confounder: education → {income, health}\n")
cat("y  - Chain/Mediator: exercise → fitness → satisfaction\n")
cat("z  - Collider: {programming, communication} → job offer\n")

# Optional: Save datasets to CSV for later use
# write_csv(x, "x_fork_data.csv")
# write_csv(y, "y_chain_data.csv")
# write_csv(z, "z_collider_data.csv")
