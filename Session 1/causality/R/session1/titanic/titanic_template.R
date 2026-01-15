###############################################################################
###############################################################################
#
#  R SESSION 1 - INTRODUCTION TO R & RSTUDIO (TITANIC VERSION)
#  CEU Causality Economics Course
#
###############################################################################
###############################################################################
#
#  NOTE: This template covers more material than we can complete in one session.
#  Any sections we don't finish are for you to complete on your own.
#  Solutions are provided in titanic_answers.R
#
#  This version uses the famous Titanic dataset instead of made-up student data.
#  See titanic_cheatsheet.R for variable naming conventions used.
#
###############################################################################
#
#  ESTIMATED TIMELINE:
#  -------------------
#  Section 0:  Setup                    ~5 min
#  Section 1:  Logging                  ~5 min
#  Section 2:  For-loops                ~10 min
#  Section 3:  Functions                ~10 min
#  Section 4:  Data types               ~15 min
#  Section 5:  Operators & indexing     ~15 min
#  Section 6:  Dates                    ~10 min
#  Section 7:  Exploring Titanic data   ~15 min
#  Section 8:  Importing data           ~5 min
#  Section 9:  Export/import practice   ~15 min
#  Section 10: Data manipulation BASE R ~20 min
#  Section 11: Tidyverse                ~20 min
#  Section 11F: For-loop vs Tidyverse   ~10 min
#  Section 12: Combine data             ~15 min
#  Section 13: Visualization            ~15 min
#  Section 14: Analysis                 ~15 min
#  Section 15: Custom functions         ~60 min
#  -------------------
#  FULL COVERAGE: ~220 min (3.5+ hours)
#
###############################################################################
###############################################################################


###############################################################################
# 0) Working directory + packages
###############################################################################

# TASK: Check your current working directory with getwd()

# TASK: Create a "data" directory if it doesn't exist
#       (hint: use dir.exists() to check, dir.create() to create)

# TASK: Load the following packages using library():
#       - tidyverse (for data manipulation and visualization)
#       - titanic (for the Titanic dataset)
#       - haven (for SPSS and Stata files)
#       - readxl (for Excel files)
#       - writexl (for writing Excel files)

# TASK: Load the titanic_train dataset
#       (hint: after loading titanic package, use data(titanic_train))


###############################################################################
# 1) Logging
###############################################################################

# TASK: Print "Hello Titanic!" using print()

# TASK: Print "Hello Titanic!" using cat() and notice the difference

# TASK: Use cat() to print multiple strings on separate lines
#       (hint: use \n for newline)

# TASK: Use cat() to print text with custom spacing and line breaks


###############################################################################
# 2) for-loops
###############################################################################

# TASK: Create a for-loop that iterates over a sequence of numbers you choose

# TASK: Inside the loop, print the iteration number and perform some action
#       (hint: use cat() or print() with the loop variable)


###############################################################################
# 3) Functions 
###############################################################################

# TASK: Write a function that takes a parameter and performs an operation

# TASK: Inside the function, perform a calculation and return the result

# TASK: Call your function with different arguments to test it


###############################################################################
# 4) Data types & objects
###############################################################################

# TASK: Create a numeric variable and assign it a number

# TASK: Create a character variable and assign it a text string

# TASK: Create a logical variable (TRUE or FALSE)

# TASK: Create variables with NULL and NA values

# TASK: Use class() to check the data type of each variable

# TASK: Convert your character variable to numeric using as.numeric()

# TASK: Convert your numeric variable to character using as.character()

# TASK: Convert a numeric variable to logical using as.logical()

# TASK: Create a factor from a vector of categories and examine its levels

# TASK: Convert a numeric vector to factor, then convert it back to character

# TASK: Use is.na() to identify which of your variables contain missing values


###############################################################################
# 5) Operators, logical statements, indexing
###############################################################################

# TASK: Create two variables with numeric values and perform arithmetic operations

# TASK: Test logical comparisons between your variables (==, !=, <, >, <=, >=)

# TASK: Create a vector with several numeric elements

# TASK: Use logical indexing to select elements that meet certain conditions
#       (hint: combine conditions with | for OR, & for AND, ! for NOT)

# TASK: Use negative indexing to exclude an element from your vector

# TASK: Extract elements at specific positions from your vector

# TASK: Create a vector with some missing values and calculate its mean
#       (hint: use na.rm = TRUE parameter)

# TASK: Calculate vector length and perform arithmetic operations on the whole vector

# TASK: Use the %in% operator to check if elements belong to a set
#       (hint: %in% checks whether each element appears in a vector)
#       Example: c(1, 5, 10) %in% c(1, 2, 3, 4, 5)  # Returns: TRUE TRUE FALSE


###############################################################################
# 6) Dates: as.Date() + basic manipulation
###############################################################################

# NOTE: The Titanic departed April 10, 1912 and sank April 15, 1912

# TASK: Create a vector of date strings in format "mm/dd/yy"

# TASK: Convert to Date objects using as.Date() with the correct format parameter
#       (hint: check ?as.Date for format codes like %m, %d, %y)

# TASK: Do the same for dates in "yyyy-mm-dd" format

# TASK: Add/subtract days from a date

# TASK: Extract year, month, and day components using format()
#       (hint: format(myDate, "%Y") for year, "%m" for month, "%d" for day)


###############################################################################
# 7) Exploring the Titanic data (instead of creating data frames)
###############################################################################

# NOTE: We'll use titanic_train which is already loaded from the titanic package
#       Variables: PassengerId, Survived, Pclass, Name, Sex, Age, SibSp, Parch,
#                  Ticket, Fare, Cabin, Embarked

# TASK: Look at the first few rows using head()

# TASK: Examine structure with str()

# TASK: Get summary statistics with summary()

# TASK: Check dimensions with dim()

# TASK: How many passengers total? (hint: nrow())

# TASK: How many survived? (hint: sum() on Survived column)

# TASK: What are the unique embarkation ports? (hint: unique() on Embarked)

# TASK: How many missing values in Age? (hint: sum() with is.na())


###############################################################################
# 8) Importing data: which function/package for which file type
###############################################################################

# NOTE: Different file types require different functions
# .txt  -> read.table() (base R)
# .csv  -> read.csv()   (base R) OR readr::read_csv() (tidyverse)
# .xlsx -> readxl::read_excel()  (readxl)
# .sav  -> haven::read_sav()     (haven - SPSS files)
# .dta  -> haven::read_dta()     (haven - Stata files)


###############################################################################
# 9) Exporting + importing the Titanic dataset (CSV, TXT, XLSX, SAV, DTA)
###############################################################################

# TASK: Export titanic_train as CSV using write.csv()
#       (hint: use row.names = FALSE)

# TASK: Read it back using read.csv()

# TASK: Read it using readr::read_csv() (tidyverse version)

# TASK: Export as TSV (tab-separated) using write.table() with sep="\t"

# TASK: Read the TSV file using read.table() with sep="\t" and header=TRUE

# TASK: Export as Excel using write_xlsx()

# TASK: Read Excel file using read_excel()

# TASK: Export as SPSS (.sav) using write_sav() and read using read_sav()

# TASK: Export as Stata (.dta) using write_dta() and read using read_dta()


###############################################################################
# 10) Data manipulation - BASE R
###############################################################################

# (A) SELECT columns
# TASK: Select specific columns from titanic_train using [, c(...)] indexing

# (B) SELECT rows
# TASK: Filter to specific rows using logical indexing with $
#       (e.g., first class passengers only)

# (C) ADD or MODIFY columns
# TASK: Add a FamilySize column (SibSp + Parch + 1)
# TASK: Add an AgeGroup column using ifelse() ("Child" if Age < 18, else "Adult")

# (D) TRANSMUTE (select and modify columns, keep only selected ones)
# TASK: Create a new data frame with only selected and derived columns
# TASK: Use ifelse() to create a FareLevel variable ("High" if Fare > 50)

# (E) GROUP summaries
# TASK: Calculate mean Fare by Pclass using aggregate()
# TASK: Create frequency tables using table()
# TASK: Calculate proportions using prop.table()


###############################################################################
# 11) Data manipulation - TIDYVERSE (%>%) in parallel
###############################################################################

# (A) SELECT columns (tidyverse)
# TASK: Use select() to choose columns
#       (hint: pipe with %>% from a data frame)

# (B) SELECT rows (tidyverse)
# TASK: Use filter() to keep specific rows (e.g., survivors only)

# (C) MUTATE (tidyverse)
# TASK: Use mutate() to add or modify columns

# (D) TRANSMUTE (tidyverse)
# TASK: Use transmute() to create a data frame with only selected columns

# (E) GROUP summaries (tidyverse)
# TASK: Use group_by() and summarise() to calculate grouped statistics
#       (hint: use n() to count observations)


###############################################################################
# 11F) Comparison: FOR LOOP vs TIDYVERSE (same result, different approach)
###############################################################################

# TASK: Write a for-loop to calculate mean Fare for each Pclass
#       (hint: iterate through 1:3, filter and calculate for each)

# TASK: Accomplish the same task using tidyverse with group_by() and summarise()

# TASK: Compare the two results and note which approach is more readable


###############################################################################
# 12) Combine data (adding columns, sampling, and binding)
###############################################################################

# (A) ADD a new column based on conditions
# TASK: Add a TicketClass column using ifelse()
#       (Pclass 1 = "First", Pclass 2 = "Second", Pclass 3 = "Third")

# (B) SAMPLING FUNCTIONS - Create functions that sample from your data
# TASK: Write a function called samplePassengers() that:
#       - Takes a data frame and a number of passengers to sample
#       - Has an option for sampling with or without replacement
#       - Returns a new data frame with randomly selected rows
#       (hint: use sample() to generate random indices, then use [ ] to extract rows)

# TASK: Use your samplePassengers() function to create a new dataset
#       - Sample 50 passengers with replacement
#       - Store the result

# TASK: Use your samplePassengers() function to sample without replacement
#       - Sample 100 passengers without replacement
#       - Store the result

# (C) COMBINE DATASETS
# TASK: Split titanic_train by Pclass, then bind back together using rbind()
# TASK: Do the same using bind_rows() (tidyverse)

# (D) COMPARE & FILTER
# TASK: Examine dimensions of survivors vs non-survivors subsets
# TASK: Use %in% to find passengers from specific embarkation ports


###############################################################################
# 13) Visualization (ggplot2 via tidyverse)
###############################################################################

# TASK: Create a scatter plot of Age vs Fare, colored by Survived
#       (hint: use ggplot(), aes(x=..., y=..., color=...), geom_point(), labs())

# TASK: Create a scatter plot with a regression line
#       (hint: add geom_smooth(method="lm", formula=y~x, se=FALSE))


###############################################################################
# 14) Analysis (correlation, t-test, OLS regression)
###############################################################################

# TASK: Calculate correlation between Age and Fare
#       (hint: use cor() with use="complete.obs" for missing values)

# TASK: Perform a t-test comparing Fare between survivors and non-survivors
#       (hint: use t.test() with formula syntax: Fare ~ Survived)

# TASK: Run an OLS regression: Fare ~ Age + Pclass
#       (hint: use lm() and summarize with summary())

# TASK: Run a second regression adding Sex as predictor

# TASK: Display regression results using texreg::screenreg() if available

# TASK: Display regression results using stargazer::stargazer() if available


###############################################################################
# 15) Custom Functions: Building Blocks for Understanding Distributions
###############################################################################

# In this section, you'll create your own versions of statistical functions
# to understand how they work under the hood

# (A) MEAN - Calculate the average
# TASK: Write a function called myMean() that takes a vector and returns the average
#       (hint: sum all values and divide by how many there are)

# (B) VARIANCE - Calculate spread of data
# TASK: Write a function called myVar() that calculates variance
#       (hint: find average of squared deviations from the mean)

# (C) STANDARD DEVIATION - Square root of variance
# TASK: Write a function called mySd() that calculates standard deviation
#       (hint: take square root of variance)

# (D) NORMAL DISTRIBUTION - Generate random samples from normal distribution
# TASK: Write a function called myRnorm() that generates random samples
#       Parameters: n (number of samples), mean, sd (standard deviation)
#       (hint: create random uniform samples and transform them)
#       Strategy: Use Central Limit Theorem with sum of uniform random numbers
#       - Generate 12 uniform random numbers using runif()
#       - Sum them (why 12? Makes it close to normal)
#       - Subtract 6 (centers around 0)
#       - Scale by sd and shift by mean: result * sd + mean

# TASK: Test your custom myRnorm() function
#       Generate 100 samples from your normal distribution
#       Use myMean(), mySd() to verify the results
#       Create a histogram to visualize

# TASK: Simulate sampling distribution with your custom function
#       Take many samples of size 30, calculate their means
#       Plot histogram of sample means
#       Compare to theoretical normal distribution


###############################################################################
# Extra: Verify your functions against R's built-in functions
###############################################################################

# TASK: Compare your custom myMean() with R's mean()
# TASK: Compare your custom myVar() with R's var()
# TASK: Compare your custom mySd() with R's sd()
# TASK: Compare your custom myRnorm() samples with rnorm() using histograms


###############################################################################
###############################################################################
#
#  END OF TITANIC TEMPLATE
#
#  Any sections we didn't cover in class are for you to complete on your own.
#  Check titanic_answers.R for complete solutions.
#
###############################################################################
###############################################################################

