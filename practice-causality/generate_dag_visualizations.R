# ============================================================================
# Generate DAG Visualizations and Regression Analyses
# ============================================================================
# This script:
# - Creates causal DAGs for each scenario
# - Generates synthetic data
# - Runs regression analyses
# - Saves visualization images
# - Saves regression results
# ============================================================================

library(dagitty)
library(ggplot2)
library(png)
library(gridExtra)
library(tidyverse)

source("build_scenarios.R")

# ============================================================================
# SCENARIO 1: CAUSAL CHAIN
# ============================================================================

cat("\n=== SCENARIO 1: CAUSAL CHAIN ===\n")

# Create DAG
dag1 <- dagitty(scenarios[[1]]$dag_formula)

# Generate data
data1 <- scenarios[[1]]$data_generation(n = 500)

# Create visualization
pdf("images/scenario1_dag.pdf", width = 8, height = 6)
plot(dag1)
title(main = scenarios[[1]]$title, cex.main = 1.5)
dev.off()

# Run regressions
cat("\nCorrect specification (Total Effect):\n")
model1_correct <- lm(ExamScore ~ Coffee, data = data1)
print(summary(model1_correct))

cat("\nWrong specification (Controlling for Mediator):\n")
model1_wrong <- lm(ExamScore ~ Coffee + Caffeine, data = data1)
print(summary(model1_wrong))

# Visualize the difference
regression_comparison1 <- data.frame(
  Specification = c("Total Effect\n(ExamScore ~ Coffee)", "Wrong: Blocking Mediator\n(ExamScore ~ Coffee + Caffeine)"),
  CoffeeCoefficient = c(coef(model1_correct)[2], coef(model1_wrong)[2]),
  PValue = c(
    summary(model1_correct)$coefficients[2, 4],
    summary(model1_wrong)$coefficients[2, 4]
  )
)

cat("\nRegression Comparison:\n")
print(regression_comparison1)

# Save regression results
sink("results/scenario1_regression_results.txt")
cat("=== SCENARIO 1: CAUSAL CHAIN ===\n")
cat("\nStory:", scenarios[[1]]$story, "\n\n")
cat("DAG:", scenarios[[1]]$dag_formula, "\n\n")
cat("Causal Explanation:", scenarios[[1]]$causal_explanation, "\n\n")
cat("CORRECT: ExamScore ~ Coffee\n")
cat("Summary:\n")
print(summary(model1_correct))
cat("\n\nWRONG: ExamScore ~ Coffee + Caffeine\n")
cat("Summary:\n")
print(summary(model1_wrong))
cat("\nWhy this is wrong: Controlling for Caffeine (the mediator) blocks the main causal pathway,\n")
cat("making the effect of Coffee disappear. If you want the total effect, don't control for mediators!\n")
sink()

# ============================================================================
# SCENARIO 2: CAUSAL FORK (CONFOUNDER)
# ============================================================================

cat("\n=== SCENARIO 2: CAUSAL FORK ===\n")

dag2 <- dagitty(scenarios[[2]]$dag_formula)

data2 <- scenarios[[2]]$data_generation(n = 500)

pdf("images/scenario2_dag.pdf", width = 8, height = 6)
plot(dag2)
title(main = scenarios[[2]]$title, cex.main = 1.5)
dev.off()

cat("\nNaive specification (Ignoring confounder):\n")
model2_naive <- lm(Health ~ Education, data = data2)
print(summary(model2_naive))

cat("\nCorrect specification (Controlling for confounder SES):\n")
model2_correct <- lm(Health ~ Education + SES, data = data2)
print(summary(model2_correct))

sink("results/scenario2_regression_results.txt")
cat("=== SCENARIO 2: CAUSAL FORK (CONFOUNDER) ===\n")
cat("\nStory:", scenarios[[2]]$story, "\n\n")
cat("DAG:", scenarios[[2]]$dag_formula, "\n\n")
cat("Causal Explanation:", scenarios[[2]]$causal_explanation, "\n\n")
cat("NAIVE (WRONG): Health ~ Education\n")
cat("Summary:\n")
print(summary(model2_naive))
cat("\n\nCORRECT: Health ~ Education + SES\n")
cat("Summary:\n")
print(summary(model2_correct))
cat("\nWhy the naive model was wrong: SES is a confounder. It causes both Education and Health.\n")
cat("If you ignore it, you get a biased estimate of the Education-Health relationship.\n")
cat("The true relationship (after controlling for SES) is much weaker than it appears!\n")
sink()

# ============================================================================
# SCENARIO 3: COLLIDER
# ============================================================================

cat("\n=== SCENARIO 3: COLLIDER ===\n")

dag3 <- dagitty(scenarios[[3]]$dag_formula)

data3 <- scenarios[[3]]$data_generation(n = 500)

pdf("images/scenario3_dag.pdf", width = 8, height = 6)
plot(dag3)
title(main = scenarios[[3]]$title, cex.main = 1.5)
dev.off()

cat("\nFull population (CORRECT): Talent ~ HardWork\n")
model3_full <- lm(HardWork ~ Talent, data = data3)
print(summary(model3_full))

cat("\nSubset to successful only (WRONG - COLLIDER BIAS):\n")
data3_successful <- data3[data3$Success == 1, ]
model3_biased <- lm(HardWork ~ Talent, data = data3_successful)
print(summary(model3_biased))

sink("results/scenario3_regression_results.txt")
cat("=== SCENARIO 3: COLLIDER ===\n")
cat("\nStory:", scenarios[[3]]$story, "\n\n")
cat("DAG:", scenarios[[3]]$dag_formula, "\n\n")
cat("Causal Explanation:", scenarios[[3]]$causal_explanation, "\n\n")
cat("CORRECT (Full Population): HardWork ~ Talent\n")
cat("Summary:\n")
print(summary(model3_full))
cat("\n\nWRONG (Subset to Success = 1 only): HardWork ~ Talent\n")
cat("Summary:\n")
print(summary(model3_biased))
cat("\nWhy this is wrong: By conditioning on the collider (Success), we create spurious correlation.\n")
cat("In the full population, talent and hard work are independent. But among the successful,\n")
cat("they appear negatively correlated (selection bias / collider bias).\n")
sink()

# ============================================================================
# SCENARIO 4: COMPLEX (FORK + CHAIN)
# ============================================================================

cat("\n=== SCENARIO 4: COMPLEX (FORK + CHAIN) ===\n")

dag4 <- dagitty(scenarios[[4]]$dag_formula)

data4 <- scenarios[[4]]$data_generation(n = 500)

pdf("images/scenario4_dag.pdf", width = 8, height = 6)
plot(dag4)
title(main = scenarios[[4]]$title, cex.main = 1.5)
dev.off()

cat("\nTotal effect of ParentEducation on CollegeAdmission:\n")
model4_total <- glm(CollegeAdmission ~ ParentEducation, data = data4, family = binomial())
print(summary(model4_total))

cat("\nEffect of StudentResources (CONFOUNDED):\n")
model4_confounded <- glm(CollegeAdmission ~ StudentResources, data = data4, family = binomial())
print(summary(model4_confounded))

cat("\nEffect of StudentResources (CONTROLLING for aptitude and GPA):\n")
model4_correct <- glm(CollegeAdmission ~ StudentResources + StudentAptitude + GPA, data = data4, family = binomial())
print(summary(model4_correct))

sink("results/scenario4_regression_results.txt")
cat("=== SCENARIO 4: COMPLEX (FORK + CHAIN) ===\n")
cat("\nStory:", scenarios[[4]]$story, "\n\n")
cat("DAG:", scenarios[[4]]$dag_formula, "\n\n")
cat("Causal Explanation:", scenarios[[4]]$causal_explanation, "\n\n")
cat("Total Effect Model: CollegeAdmission ~ ParentEducation\n")
cat("Summary:\n")
print(summary(model4_total))
cat("\n\nConfounded Model (WRONG): CollegeAdmission ~ StudentResources\n")
cat("Summary:\n")
print(summary(model4_confounded))
cat("\n\nCorrect Model: CollegeAdmission ~ StudentResources + StudentAptitude + GPA\n")
cat("Summary:\n")
print(summary(model4_correct))
cat("\nNote: This scenario combines fork (confounding) and chain (mediation) structures.\n")
cat("Proper regression specification depends on your research question!\n")
sink()

cat("\n\n=== ALL VISUALIZATIONS AND RESULTS SAVED ===\n")
cat("Images saved in: images/\n")
cat("Results saved in: results/\n")
