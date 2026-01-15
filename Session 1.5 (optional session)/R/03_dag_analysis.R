# ==============================================================================
# DAG ANALYSIS: Formalizing Causal Graphs with dagitty
# ==============================================================================
#
# WHY THIS MATTERS:
# In earlier scripts, we drew causal graphs by hand and used intuition to decide
# which variables to control for. This is good for learning, but can be error-prone.
#
# Directed Acyclic Graphs (DAGs) provide a formal mathematical language for:
# 1. Specifying exactly which relationships are causal
# 2. Checking if our regression specification will give unbiased estimates
# 3. Finding the minimal set of variables we must control for
#
# The dagitty package automates this reasoning for us!
# ==============================================================================

library(dagitty)
library(ggdag)
library(tidyverse)

# Load the three datasets
source("01_data_generation.R")

# ==============================================================================
# EXAMPLE 1: FORK / CONFOUNDER (Dataset x)
# ==============================================================================

# BACKGROUND:
# We have three variables: education_years, income_numeric, health_score
# We want to estimate the causal effect of income on health.
# But intuitively, we suspect education affects both income and health.
# This would create a "fork" structure where education is a common cause.
#
# Our question: What regression should we run to get an unbiased estimate
# of the income → health effect?

# DEFINE THE CAUSAL STRUCTURE:
# dagitty uses simple syntax: parent -> child
# This means: parent causes child

dag_fork <- dagitty('
  dag {
    education_years -> income_numeric
    education_years -> health_score
  }
')

cat("EXAMPLE 1: FORK/CONFOUNDER\n")
cat("Causal structure:\n")
cat("  education_years → income_numeric\n")
cat("  education_years → health_score\n\n")

# VISUALIZE:
# Plot helps us see the structure. In a fork, the common cause (education) is at the top,
# and it has arrows pointing down to both outcomes.

plot_fork <- ggdag(dag_fork) +
  theme_dag() +
  ggtitle("Fork: Education is a common cause of income and health")
print(plot_fork)

# QUERY THE DAG:
# The key insight of dagitty is that we can query: "What do I need to control for?"
# adjustmentSets() tells us the minimal set of variables we must condition on
# to get an unbiased estimate of our exposure → outcome effect.

cat("\n\nQUESTION: What variables must we control to estimate income → health?\n")

adj_sets_fork <- adjustmentSets(
  dag_fork,
  exposure = "income_numeric",
  outcome = "health_score"
)

cat("ANSWER from dagitty:\n")
if (length(adj_sets_fork) == 0) {
  cat("(Empty set - no adjustment needed)\n")
} else {
  # Print the adjustment sets
  for (i in seq_along(adj_sets_fork)) {
    cat("  Set ", i, ": ", toString(adj_sets_fork[[i]]), "\n", sep = "")
  }
}

cat("\nINTERPRETATION:\n")
cat("We must control for education_years.\n")
cat("This blocks the confounding path: income ← education → health\n")
cat("Correct regression: lm(health_score ~ income_numeric + education_years)\n\n")

# ADDITIONAL INSIGHT: Conditional Independencies
# Another useful thing dagitty can tell us is which variables are independent
# given that we condition on others.
# In a fork, once we condition on the common cause, the two outcomes become independent.

indeps_fork <- impliedConditionalIndependencies(dag_fork)
cat("Conditional independencies implied by this DAG:\n")
print(indeps_fork)
cat("Meaning: income_numeric ⊥ health_score | education_years\n")
cat("(Income and health are independent, conditional on education)\n\n")


# ==============================================================================
# EXAMPLE 2: CHAIN / MEDIATOR (Dataset y)
# ==============================================================================

# BACKGROUND:
# We have: exercise_hours → fitness_score → life_satisfaction
# We want to estimate the effect of exercise on satisfaction.
#
# The question: Do we need to control for fitness?
# Intuitively, no! Fitness is HOW exercise affects satisfaction.
# Controlling for fitness would block the effect we want to study.
#
# Let's verify this with dagitty.

dag_chain <- dagitty('
  dag {
    exercise_hours -> fitness_score
    fitness_score -> life_satisfaction
  }
')

cat("\nEXAMPLE 2: CHAIN/MEDIATOR\n")
cat("Causal structure:\n")
cat("  exercise_hours → fitness_score → life_satisfaction\n\n")

# VISUALIZE:
plot_chain <- ggdag(dag_chain) +
  theme_dag() +
  ggtitle("Chain: Exercise affects satisfaction through fitness")
print(plot_chain)

# QUERY THE DAG:
cat("\nQUESTION: What variables must we control to estimate exercise → satisfaction?\n")

adj_sets_chain <- adjustmentSets(
  dag_chain,
  exposure = "exercise_hours",
  outcome = "life_satisfaction"
)

cat("ANSWER from dagitty:\n")
if (length(adj_sets_chain) == 0) {
  cat("(Empty set - no adjustment needed)\n")
} else {
  for (i in seq_along(adj_sets_chain)) {
    cat("  Set ", i, ": ", toString(adj_sets_chain[[i]]), "\n", sep = "")
  }
}

cat("\nINTERPRETATION:\n")
cat("We do NOT need to control for anything (empty adjustment set).\n")
cat("DO NOT control for fitness! It's the mechanism (mediator).\n")
cat("If you control for fitness, you block the causal path.\n")
cat("Correct regression: lm(life_satisfaction ~ exercise_hours)\n\n")

# CONDITIONAL INDEPENDENCIES:
indeps_chain <- impliedConditionalIndependencies(dag_chain)
cat("Conditional independencies:\n")
print(indeps_chain)
cat("Meaning: exercise_hours ⊥ life_satisfaction | fitness_score\n")
cat("(Exercise and satisfaction are independent conditional on fitness)\n")
cat("This confirms that fitness fully mediates the effect!\n\n")


# ==============================================================================
# EXAMPLE 3: COLLIDER (Dataset z)
# ==============================================================================

# BACKGROUND:
# We have: programming_score, communication_score, got_job_offer
# Both skills independently affect whether you get the job.
#
# The danger: If we only look at job offer recipients (conditioning on the collider),
# we create a spurious correlation between the two skills.
# Let's verify that dagitty warns us about this.

dag_collider <- dagitty('
  dag {
    programming_score -> got_job_offer
    communication_score -> got_job_offer
  }
')

cat("EXAMPLE 3: COLLIDER\n")
cat("Causal structure:\n")
cat("  programming_score → got_job_offer\n")
cat("  communication_score → got_job_offer\n\n")

# VISUALIZE:
plot_collider <- ggdag(dag_collider) +
  theme_dag() +
  ggtitle("Collider: Both skills cause job offers")
print(plot_collider)

# QUERY THE DAG:
cat("\nQUESTION: What variables must we control to estimate programming → communication?\n")

adj_sets_collider <- adjustmentSets(
  dag_collider,
  exposure = "programming_score",
  outcome = "communication_score"
)

cat("ANSWER from dagitty:\n")
if (length(adj_sets_collider) == 0) {
  cat("(Empty set - no adjustment needed)\n")
} else {
  for (i in seq_along(adj_sets_collider)) {
    cat("  Set ", i, ": ", toString(adj_sets_collider[[i]]), "\n", sep = "")
  }
}

cat("\nINTERPRETATION:\n")
cat("We do NOT need to control for anything.\n")
cat("MORE IMPORTANTLY: Do NOT condition on (filter by) got_job_offer!\n")
cat("If you only study people who got hired, you create spurious correlation.\n\n")

# CONDITIONAL INDEPENDENCIES:
indeps_collider <- impliedConditionalIndependencies(dag_collider)
cat("Conditional independencies:\n")
print(indeps_collider)
cat("Meaning: programming_score ⊥ communication_score\n")
cat("(Skills are independent in the general population)\n")
cat("But NOT independent when conditioned on got_job_offer!\n\n")


# ==============================================================================
# CONNECTING DAGs TO REGRESSION SPECIFICATIONS
# ==============================================================================

cat("\n\n")
cat("PRACTICAL APPLICATION: What dagitty tells us for regression\n")
cat("===========================================================\n\n")

# FORK EXAMPLE:
cat("1. FORK (Dataset x):\n")
cat("   dagitty says: Adjust for education_years\n")
cat("   Regression: lm(health_score ~ income_numeric + education_years)\n")

model_x_correct <- lm(health_score ~ income_numeric + education_years, data = x)
cat("   Result: Income effect =", round(coef(model_x_correct)["income_numeric"], 6), "\n")
cat("   (Close to zero - correct!)\n\n")

# CHAIN EXAMPLE:
cat("2. CHAIN (Dataset y):\n")
cat("   dagitty says: Adjust for nothing (empty set)\n")
cat("   Regression: lm(life_satisfaction ~ exercise_hours)\n")

model_y_correct <- lm(life_satisfaction ~ exercise_hours, data = y)
cat("   Result: Exercise effect =", round(coef(model_y_correct)["exercise_hours"], 4), "\n")
cat("   (Positive! We capture the total effect through fitness)\n\n")

# COLLIDER EXAMPLE:
cat("3. COLLIDER (Dataset z):\n")
cat("   dagitty says: Adjust for nothing\n")
cat("   Analysis: Correlation in full population\n")

full_cor <- cor(z$programming_score, z$communication_score)
cat("   Result: Correlation =", round(full_cor, 3), "\n")
cat("   (Close to zero - they're independent)\n")

# Show what happens if we wrongly condition:
z_hired <- z[z$got_job_offer == 1, ]
hired_cor <- cor(z_hired$programming_score, z_hired$communication_score)
cat("   If we only look at hired people: Correlation =", round(hired_cor, 3), "\n")
cat("   (Negative! We created spurious correlation)\n\n")

cat("===========================================================\n")
cat("KEY TAKEAWAY:\n")
cat("dagitty automates the reasoning we did intuitively before.\n")
cat("Use it to check your assumptions and find the right regression!\n")
