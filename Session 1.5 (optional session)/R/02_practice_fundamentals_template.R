# ==============================================================================
# PRACTICE: FUNDAMENTAL R SKILLS FOR CAUSAL INFERENCE
# TEMPLATE - Complete the exercises below
# ==============================================================================
# Instructions:
# 1. Load the datasets first by running 01_data_generation.R
# 2. Work through each section, following the comments
# 3. Fill in the code where indicated
# 4. Check your results against 02_practice_fundamentals_solutions.R if stuck
# ==============================================================================

# First, load the datasets
source("01_data_generation.R")

library(tidyverse)
library(ggplot2)



# ==============================================================================
# PART 1: SUBSETTING & FILTERING (Using dataset x - Fork example)
# ==============================================================================

# 1.1: ACCESSING COLUMNS
# Goal: Learn how to access a single column using the $ operator
# Try this: x$gender (this gets the gender column from dataset x)

# TASK 1.1a: Print the first 6 values of the gender column
# Hint: Use head() function
# Your code here:


# 1.2: LOGICAL FILTERING
# Goal: Filter rows based on conditions
# We want to find people with high income (> 60000) and look at their health

# TASK 1.2a: Create a subset with only high earners (income > 60000)
# Hint: Use x[condition, ] where condition is a logical statement
# Your code here:

# TASK 1.2b: Calculate the mean health score for high earners
# Hint: Use mean() on the column from your filtered data
# Your code here:

# 1.3: MULTIPLE CONDITIONS
# Goal: Combine conditions with & (AND) and | (OR)

# TASK 1.3a: How many people have BOTH high education (> 15 years) AND high income (> 70000)?
# Hint: Use nrow() to count rows, & to combine conditions
# Your code here:

# TASK 1.3b: How many people have EITHER young age (< 25) OR high education (> 18)?
# Hint: Use | for OR
# Your code here:

# 1.4: CREATING NEW VARIABLES WITH ifelse()
# Goal: Create a binary variable based on a condition
# The ifelse() function: ifelse(condition, value_if_true, value_if_false)

# TASK 1.4a: Create a new variable in x called "high_earner"
# Set it to 1 if income_numeric > 60000, else 0
# Hint: x$high_earner <- ifelse(condition, 1, 0)
# Your code here:

# Uncomment this to check your work:
# cat("Number of high earners:", sum(x$high_earner), "\n")

# 1.5: TIDYVERSE ALTERNATIVE: filter() and mutate()
# Goal: Do the same operations using tidyverse (more modern, cleaner syntax)

# TASK 1.5a: Use tidyverse to create a filtered dataset
# Filter x for income > 60000
# Hint: x %>% filter(income_numeric > 60000)
# Your code here:

# TASK 1.5b: Create a new column with mutate()
# Add a column called health_category with "High" if health_score > 70, else "Low"
# Hint: data %>% mutate(new_col = ifelse(condition, "High", "Low"))
# Your code here:




# ==============================================================================
# PART 2: SUMMARY STATISTICS & GROUP-WISE OPERATIONS (Dataset y - Chain example)
# ==============================================================================

# 2.1: BASIC STATISTICS
# Goal: Calculate summary statistics for a single variable

# TASK 2.1a: Calculate mean, median, and standard deviation of fitness_score
# Hint: Use mean(), median(), and sd() functions
# Your code here:

# 2.2: COMPARING GROUPS
# Goal: Split data into groups and compare them

# TASK 2.2a: Create two groups based on exercise level
# low_exercise: exercise_hours < 4
# high_exercise: exercise_hours >= 4
# Hint: Use subsetting with x[condition, ]
# Your code here (low_exercise):

# Your code here (high_exercise):

# TASK 2.2b: Calculate mean fitness for each group and compare
# Which group has higher average fitness?
# Your code here:

# 2.3: USING TIDYVERSE FOR GROUP OPERATIONS
# Goal: Use group_by() and summarize() for cleaner code

# TASK 2.3a: Create a summary table grouped by exercise level
# The table should show:
# - n = number of people in each group
# - mean_fitness = average fitness score
# - mean_satisfaction = average life satisfaction score
# Hint: y %>% mutate(exercise_level = ifelse(...)) %>% group_by(exercise_level) %>% summarize(...)
# Your code here:


# ==============================================================================
# PART 3: VISUALIZATION WITH GGPLOT2 (All datasets)
# ==============================================================================

# ==============================================================================
# PART 3: VISUALIZATION WITH GGPLOT2 (All datasets)
# ==============================================================================

# 3.1: BOXPLOT
# Goal: Create a boxplot to compare distributions across groups

# TASK 3.1a: Create a categorical income variable from income_numeric
# Categories: low (< 40000), mid (40000-70000), high (> 70000)
# Hint: Use nested ifelse() or the cut() function
# Your code here:

# TASK 3.1b: Create a boxplot with ggplot2
# x-axis: income_cat, y-axis: health_score
# Add individual points on top with geom_jitter()
# Hint: ggplot(x, aes(x = income_cat, y = health_score)) + geom_boxplot() + geom_jitter(...)
# Your code here:

# 3.2: SCATTER PLOT WITH REGRESSION LINE
# Goal: Show the relationship between two continuous variables

# TASK 3.2a: Create a scatter plot of exercise vs satisfaction
# x-axis: exercise_hours, y-axis: life_satisfaction
# Color the points by fitness_score
# Add a regression line with geom_smooth(method = "lm")
# Your code here:

# 3.3: FACETED PLOTS
# Goal: Show the same plot separately for different subgroups

# TASK 3.3a: Create boxplots of health by income
# Make separate panels for each gender using facet_wrap(~ gender)
# Your code here:


# ==============================================================================
# PART 4: REGRESSION & CAUSAL INFERENCE (All datasets)
# ==============================================================================

# ==============================================================================
# PART 4: REGRESSION & CAUSAL INFERENCE (All datasets)
# ==============================================================================

# 4.1: FORK STRUCTURE
# Question: Does higher income improve health?
# True answer: No - education is the confounder
# Your job: Show that controlling for education removes the spurious effect

# TASK 4.1a: Regression WITHOUT controlling for education
# Fit: health_score ~ income_numeric
# Look at the coefficient on income. Is it significantly different from 0?
# Your code here:

# TASK 4.1b: Regression WITH education as a control
# Fit: health_score ~ income_numeric + education_years
# Compare the coefficient on income to task 4.1a. Did it change?
# Your code here:

# TASK 4.1c: Explain what you found
# Write a comment explaining why the coefficient changed (or stayed the same)
# Your reflection:

# 4.2: CHAIN STRUCTURE
# Question: Does exercise improve life satisfaction?
# True answer: Yes - through the mechanism of improved fitness
# Your job: Show what happens with and without controlling for the mediator

# TASK 4.2a: Regression WITHOUT controlling for fitness
# Fit: life_satisfaction ~ exercise_hours
# This coefficient shows the TOTAL effect (direct + through fitness)
# Your code here:

# TASK 4.2b: Regression WITH fitness as a control
# Fit: life_satisfaction ~ exercise_hours + fitness_score
# What happened to the exercise coefficient? Why?
# Your code here:

# TASK 4.2c: Explain what you found
# Write a comment: Why does controlling for fitness change the result?
# Your reflection:

# 4.3: COLLIDER STRUCTURE
# Question: Are programming and communication skills correlated?
# True answer: No - they're independent in the general population
# Your job: Show that conditioning on the collider creates spurious correlation

# TASK 4.3a: Correlation in the FULL population (z)
# Calculate the correlation between programming_score and communication_score
# What do you expect? (hint: should be close to 0)
# Your code here:

# TASK 4.3b: Correlation among those who GOT JOB OFFERS
# Subset z to only include people with got_job_offer == 1
# Calculate the correlation in that subset
# Your code here:

# TASK 4.3c: Compare and explain
# Write a comment: Why is the second correlation different from the first?
# This is collider bias!
# Your reflection:


# ==============================================================================
# REFLECTION & SYNTHESIS
# ==============================================================================

# 1. FORK / CONFOUNDER (education → {income, health})
# Question: Why is education important to control for?
# Hint: Think about what happens if you don't.
# Your answer:

# 2. CHAIN / MEDIATOR (exercise → fitness → satisfaction)
# Question: Why is it WRONG to control for fitness?
# Hint: What mechanism would you be blocking?
# Your answer:

# 3. COLLIDER (programming, communication → job offer)
# Question: Why does the correlation change when we filter by job offers?
# Hint: Think about what "getting hired" tells us about the skills.
# Your answer:

# FINAL QUESTION:
# How would these three examples change if we had real data instead of simulated?
# Would the conclusions still hold? Why or why not?
# Your thoughts:
