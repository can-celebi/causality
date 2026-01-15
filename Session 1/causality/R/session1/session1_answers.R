###############################################################################
###############################################################################
#
#  R SESSION 1 - ANSWER KEY
#  CEU Causality Economics Course
#
#  This file contains complete solutions for all tasks in session1_template.R
#
#  STYLE NOTES:
#  - camelCase naming (e.g., myVar, studyHrs)
#  - Short but intuitive names
#  - Lots of spacing for visibility (especially in base R)
#  - Step-by-step approach for complex operations
#  - Both BASE R and PACKAGE versions where applicable
#
###############################################################################
###############################################################################


###############################################################################
# 0) Working directory + packages
###############################################################################

# TASK: Check your current working directory with getwd()
getwd()

# TASK: Create a "data" directory if it doesn't exist

# --- BASE R ---
dirExists <- dir.exists("data")
cat("Does 'data' directory exist?", dirExists, "\n")

if ( !dirExists ) {
  dir.create("data")
  cat("Created 'data' directory\n")
}

# TASK: Load packages
library(tidyverse)
library(haven)
library(readxl)
library(writexl)
library(lubridate)


###############################################################################
# 1) Logging
###############################################################################

# TASK: Print "Hello world!" using print()
print("Hello world!")
# Output: [1] "Hello world!"

# TASK: Print "Hello world!" using cat() and notice the difference
cat("Hello world!\n")
# Output: Hello world!
# NOTE: cat() doesn't show [1] or quotes - cleaner for messages

# TASK: Use cat() to print multiple strings on separate lines
cat("Line one\n")
cat("Line two\n")
cat("Line three\n")

# Or all at once:
cat("First\nSecond\nThird\n")

# TASK: Use cat() to print text with custom spacing and line breaks
cat("\n")
cat("============\n")
cat("  HEADER    \n")
cat("============\n")
cat("\n")


###############################################################################
# 2) for-loops
###############################################################################

# TASK: Create a for-loop that iterates over a sequence

# --- BASE R (verbose, educational) ---
myNums <- 1:5

for ( i in myNums ) {

  cat("Iteration:", i, "\n")

}

# TASK: Inside the loop, print iteration and perform action

# --- BASE R (step by step) ---
total <- 0

for ( i in 1:10 ) {

  # Print where we are
  cat("i =", i, "\n")

  # Do something (accumulate sum)
  total <- total + i

  # Show running total
  cat("  running total:", total, "\n")

}

cat("\nFinal total:", total, "\n")


###############################################################################
# 3) Functions (simple + explicit return())
###############################################################################

# TASK: Write a function that takes a parameter and performs operation

# --- BASE R ---
doubleIt <- function( x ) {

  result <- x * 2

  return( result )

}

# TASK: Call function with different arguments
doubleIt( 5 )    # 10
doubleIt( 10 )   # 20
doubleIt( 0.5 )  # 1

# Another example: add two numbers
addTwo <- function( a, b ) {

  sumVal <- a + b

  return( sumVal )

}

addTwo( 3, 4 )   # 7
addTwo( 10, 20 ) # 30


###############################################################################
# 4) Data types & objects
###############################################################################

# TASK: Create a numeric variable
myNum <- 42
cat("myNum =", myNum, "\n")

# TASK: Create a character variable
myChar <- "Hello"
cat("myChar =", myChar, "\n")

# TASK: Create a logical variable
myBool <- TRUE
cat("myBool =", myBool, "\n")

# TASK: Create NULL and NA values
myNull <- NULL
myNa   <- NA
cat("myNull is NULL:", is.null(myNull), "\n")
cat("myNa is NA:", is.na(myNa), "\n")

# TASK: Check data types with class()
cat("\nData types:\n")
cat("class(myNum)  =", class(myNum), "\n")
cat("class(myChar) =", class(myChar), "\n")
cat("class(myBool) =", class(myBool), "\n")
cat("class(myNa)   =", class(myNa), "\n")

# TASK: Convert character to numeric
charNum <- "123"
cat("\ncharNum =", charNum, "class:", class(charNum), "\n")

numVal <- as.numeric( charNum )
cat("numVal  =", numVal, "class:", class(numVal), "\n")

# What happens with non-numeric string?
badChar <- "abc"
badNum  <- as.numeric( badChar )  # Warning: NAs introduced
cat("as.numeric('abc') =", badNum, "\n")

# TASK: Convert numeric to character
numToChar <- as.character( 456 )
cat("as.character(456) =", numToChar, "class:", class(numToChar), "\n")

# TASK: Convert numeric to logical
# 0 = FALSE, anything else = TRUE
cat("\nNumeric to logical:\n")
cat("as.logical(0)  =", as.logical(0), "\n")
cat("as.logical(1)  =", as.logical(1), "\n")
cat("as.logical(5)  =", as.logical(5), "\n")
cat("as.logical(-1) =", as.logical(-1), "\n")

# TASK: Create factor and examine levels
unis <- c("ceu", "uv", "ceu", "wu", "uv", "ceu")
cat("\nOriginal vector:", unis, "\n")

uniFactor <- factor( unis )
cat("Factor:", as.character(uniFactor), "\n")
cat("Levels:", levels(uniFactor), "\n")

# TASK: Numeric vector to factor, then to character
scores <- c(1, 2, 3, 1, 2, 3)
cat("\nOriginal scores:", scores, "\n")

scoreFactor <- factor( scores )
cat("As factor:", as.character(scoreFactor), "\n")
cat("Levels:", levels(scoreFactor), "\n")

scoreChar <- as.character( scoreFactor )
cat("Back to character:", scoreChar, "\n")

# TASK: Use is.na() to identify missing values
testVec <- c(1, NA, 3, NA, 5)
cat("\ntestVec:", testVec, "\n")
cat("is.na(testVec):", is.na(testVec), "\n")
cat("Sum of NAs:", sum(is.na(testVec)), "\n")


###############################################################################
# 5) Operators, logical statements, indexing
###############################################################################

# TASK: Create two numeric variables and perform arithmetic
a <- 10
b <- 3

cat("a =", a, "\n")
cat("b =", b, "\n")
cat("\n")

cat("a + b  =", a + b, "\n")   # Addition
cat("a - b  =", a - b, "\n")   # Subtraction
cat("a * b  =", a * b, "\n")   # Multiplication
cat("a / b  =", a / b, "\n")   # Division
cat("a %% b =", a %% b, "\n")  # Modulo (remainder)
cat("a ^ b  =", a ^ b, "\n")   # Power

# TASK: Test logical comparisons
cat("\nLogical comparisons:\n")
cat("a == b :", a == b, "\n")  # Equal
cat("a != b :", a != b, "\n")  # Not equal
cat("a < b  :", a < b, "\n")   # Less than
cat("a > b  :", a > b, "\n")   # Greater than
cat("a <= b :", a <= b, "\n")  # Less or equal
cat("a >= b :", a >= b, "\n")  # Greater or equal

# TASK: Create a vector
myVec <- c(5, 12, 3, 18, 9, 25, 1, 15)
cat("\nmyVec:", myVec, "\n")

# TASK: Logical indexing with conditions

# Elements greater than 10
big <- myVec[ myVec > 10 ]
cat("Elements > 10:", big, "\n")

# Elements less than or equal to 5
small <- myVec[ myVec <= 5 ]
cat("Elements <= 5:", small, "\n")

# Combining conditions with | (OR), & (AND), ! (NOT)

# Elements less than 5 OR greater than 15
extreme <- myVec[ myVec < 5 | myVec > 15 ]
cat("< 5 OR > 15:", extreme, "\n")

# Elements between 5 and 15 (inclusive)
middle <- myVec[ myVec >= 5 & myVec <= 15 ]
cat(">= 5 AND <= 15:", middle, "\n")

# Elements NOT equal to 12
not12 <- myVec[ myVec != 12 ]
cat("NOT 12:", not12, "\n")

# TASK: Negative indexing to exclude element
cat("\nNegative indexing:\n")
cat("myVec[-1]:", myVec[-1], "\n")       # Remove first element
cat("myVec[-c(1,3)]:", myVec[-c(1,3)], "\n")  # Remove 1st and 3rd

# TASK: Extract elements at specific positions
cat("\nPositional indexing:\n")
cat("myVec[1]:", myVec[1], "\n")         # First element
cat("myVec[3]:", myVec[3], "\n")         # Third element
cat("myVec[c(1,3,5)]:", myVec[c(1,3,5)], "\n")  # 1st, 3rd, 5th

# TASK: Vector with NAs, calculate mean
naVec <- c(10, NA, 20, NA, 30)
cat("\nnaVec:", naVec, "\n")

meanBad <- mean( naVec )          # Returns NA!
cat("mean(naVec):", meanBad, "\n")

meanGood <- mean( naVec, na.rm = TRUE )  # Ignores NAs
cat("mean(naVec, na.rm=TRUE):", meanGood, "\n")

# TASK: Vector length and arithmetic on whole vector
cat("\nlength(myVec):", length(myVec), "\n")

# Add 10 to every element
myVec + 10

# Multiply every element by 2
myVec * 2

# TASK: Use %in% operator
cat("\n%in% operator:\n")

# Check if specific values are in a set
checkVals <- c(1, 5, 10, 100)
mySet     <- c(1, 2, 3, 4, 5)

result <- checkVals %in% mySet
cat("checkVals:", checkVals, "\n")
cat("mySet:", mySet, "\n")
cat("checkVals %in% mySet:", result, "\n")

# Using %in% for filtering (much cleaner than multiple OR)
# --- BAD WAY ---
# myVec[ myVec == 5 | myVec == 12 | myVec == 25 ]

# --- GOOD WAY ---
targets <- c(5, 12, 25)
matched <- myVec[ myVec %in% targets ]
cat("Elements in {5, 12, 25}:", matched, "\n")


###############################################################################
# 6) Dates: as.Date() + basic manipulation
###############################################################################

# TASK: Create date strings in mm/dd/yy format
dateStrs <- c("01/15/24", "02/20/24", "03/10/24")
cat("Date strings:", dateStrs, "\n")

# TASK: Convert to Date objects
# Format codes: %m = month, %d = day, %y = 2-digit year, %Y = 4-digit year

# --- BASE R ---
dates1 <- as.Date( dateStrs, format = "%m/%d/%y" )
cat("Converted dates:", as.character(dates1), "\n")

# TASK: Dates in yyyy-mm-dd format (R's default)
dateStrs2 <- c("2024-01-15", "2024-02-20", "2024-03-10")
dates2 <- as.Date( dateStrs2 )  # No format needed for ISO format
cat("ISO dates:", as.character(dates2), "\n")

# TASK: Add/subtract days
today <- Sys.Date()
cat("\nToday:", as.character(today), "\n")

tomorrow <- today + 1
cat("Tomorrow:", as.character(tomorrow), "\n")

nextWeek <- today + 7
cat("Next week:", as.character(nextWeek), "\n")

lastWeek <- today - 7
cat("Last week:", as.character(lastWeek), "\n")

# TASK: Extract year, month, day using lubridate
myDate <- as.Date("2024-07-15")

# --- PACKAGE: lubridate ---
cat("\nUsing lubridate:\n")
cat("year(myDate):", year(myDate), "\n")
cat("month(myDate):", month(myDate), "\n")
cat("day(myDate):", day(myDate), "\n")

# --- BASE R alternative ---
cat("\nUsing base R:\n")
cat("format(myDate, '%Y'):", format(myDate, "%Y"), "\n")
cat("format(myDate, '%m'):", format(myDate, "%m"), "\n")
cat("format(myDate, '%d'):", format(myDate, "%d"), "\n")


###############################################################################
# 7) Data frames
###############################################################################

# TASK: Create vectors for student data

# --- BASE R (step by step, spaced out) ---

# Student IDs
studId <- c(1, 2, 3, 4, 5, 6, 7)

# Universities
uni <- c("ceu", "uv", "ceu", "wu", "uv", "ceu", "wu")

# Coffee cups per day
coffee <- c(3, 2, 5, 1, 4, 2, 3)

# Study hours per week (with missing value)
studyHrs <- c(20, 15, NA, 25, 18, 22, 30)

# TASK: Create date vector from strings
dateStrs <- c("2024-01-10", "2024-01-11", "2024-01-10",
              "2024-01-12", "2024-01-11", "2024-01-10",
              "2024-01-12")

joinDate <- as.Date( dateStrs )

# Show what we have so far
cat("studId:", studId, "\n")
cat("uni:", uni, "\n")
cat("coffee:", coffee, "\n")
cat("studyHrs:", studyHrs, "\n")
cat("joinDate:", as.character(joinDate), "\n")

# TASK: Fill missing values with sensible default

# First, find which are NA
naIdx <- is.na( studyHrs )
cat("\nNA indices:", naIdx, "\n")

# Calculate mean of non-missing
meanHrs <- mean( studyHrs, na.rm = TRUE )
cat("Mean study hours:", meanHrs, "\n")

# Fill NAs with mean
studyHrs[ naIdx ] <- meanHrs
cat("After filling:", studyHrs, "\n")

# TASK: Create examScore using formula
# Example: score = coffee * 5 + studyHrs * 2

examScore <- coffee * 5 + studyHrs * 2
cat("\nexamScore:", examScore, "\n")

# TASK: Combine into data.frame()

# --- BASE R ---
studDf <- data.frame(
  studId    = studId,
  uni       = uni,
  coffee    = coffee,
  studyHrs  = studyHrs,
  joinDate  = joinDate,
  examScore = examScore
)

cat("\nData frame created!\n")

# TASK: Examine the data frame
cat("\ndim(studDf):\n")
print( dim(studDf) )

cat("\nstr(studDf):\n")
str( studDf )

cat("\nsummary(studDf):\n")
print( summary(studDf) )


###############################################################################
# 8) Importing data: reference
###############################################################################

# .txt  -> read.table()
# .csv  -> read.csv() OR readr::read_csv()
# .xlsx -> readxl::read_excel()
# .sav  -> haven::read_sav()
# .dta  -> haven::read_dta()


###############################################################################
# 9) Exporting + importing
###############################################################################

# TASK: Export as CSV

# --- BASE R ---
write.csv( studDf, "data/students.csv", row.names = FALSE )
cat("Saved to data/students.csv\n")

# TASK: Read CSV back

# --- BASE R ---
dfCsv <- read.csv( "data/students.csv" )
cat("Read back:\n")
print( head(dfCsv) )

# --- PACKAGE: readr (tidyverse) ---
dfCsvTidy <- read_csv( "data/students.csv" )
# Note: read_csv is faster and shows column types

# TASK: Export as TSV

# --- BASE R ---
write.table( studDf, "data/students.tsv", sep = "\t", row.names = FALSE )
cat("\nSaved TSV\n")

# TASK: Read TSV

# --- BASE R ---
dfTsv <- read.table( "data/students.tsv", sep = "\t", header = TRUE )

# TASK: Export as Excel

# --- PACKAGE: writexl ---
write_xlsx( studDf, "data/students.xlsx" )
cat("Saved Excel\n")

# TASK: Read Excel

# --- PACKAGE: readxl ---
dfXl <- read_excel( "data/students.xlsx" )

# TASK: Export/import SPSS

# --- PACKAGE: haven ---
write_sav( studDf, "data/students.sav" )
dfSav <- read_sav( "data/students.sav" )

# TASK: Export/import Stata

# --- PACKAGE: haven ---
write_dta( studDf, "data/students.dta" )
dfDta <- read_dta( "data/students.dta" )


###############################################################################
# 10) Data manipulation - BASE R
###############################################################################

# (A) SELECT columns
# TASK: Select specific columns

# --- BASE R (step by step) ---
cols <- c("studId", "uni", "coffee")

dfSubset <- studDf[ , cols ]

cat("Selected columns:\n")
print( dfSubset )

# Alternative: by column index
dfSubset2 <- studDf[ , c(1, 2, 3) ]

# (B) SELECT rows
# TASK: Filter to specific rows

# --- BASE R (very explicit) ---
# Students from CEU

# Step 1: Create logical condition
isCeu <- studDf$uni == "ceu"
cat("\nisCeu:", isCeu, "\n")

# Step 2: Use it to filter
ceuStudents <- studDf[ isCeu , ]
cat("\nCEU students:\n")
print( ceuStudents )

# One-liner version:
ceuStudents <- studDf[ studDf$uni == "ceu" , ]

# (C) ADD or MODIFY columns
# TASK: Add column based on condition

# --- BASE R ---
# Add "highCoffee" column: TRUE if coffee >= 3

studDf$highCoffee <- studDf$coffee >= 3

cat("\nWith highCoffee column:\n")
print( studDf )

# TASK: Add column using lubridate

# --- PACKAGE: lubridate ---
studDf$joinYear <- year( studDf$joinDate )

cat("\nWith joinYear column:\n")
print( studDf[ , c("studId", "joinDate", "joinYear") ] )

# (D) TRANSMUTE - select and derive new columns
# TASK: Create new df with only selected/derived columns

# --- BASE R ---
newDf <- data.frame(
  id         = studDf$studId,
  university = studDf$uni,
  coffeeScore = studDf$coffee * 10
)

cat("\nTransmuted data frame:\n")
print( newDf )

# TASK: Use ifelse() for categorical

# --- BASE R ---
studDf$coffeeLevel <- ifelse(
  studDf$coffee >= 4,
  "heavy",
  "light"
)

cat("\nWith coffeeLevel:\n")
print( studDf[ , c("studId", "coffee", "coffeeLevel") ] )

# (E) GROUP summaries
# TASK: Calculate summaries by group using aggregate()

# --- BASE R (step by step) ---
# Mean coffee by university

aggResult <- aggregate(
  coffee ~ uni,
  data = studDf,
  FUN  = mean
)

cat("\nMean coffee by university:\n")
print( aggResult )

# Multiple aggregations
aggMulti <- aggregate(
  cbind(coffee, studyHrs, examScore) ~ uni,
  data = studDf,
  FUN  = mean
)

cat("\nMultiple means by university:\n")
print( aggMulti )

# TASK: Frequency tables with table()

# --- BASE R ---
uniTable <- table( studDf$uni )
cat("\nUniversity counts:\n")
print( uniTable )

# Cross-tabulation
crossTab <- table( studDf$uni, studDf$coffeeLevel )
cat("\nUni x CoffeeLevel:\n")
print( crossTab )

# TASK: Proportions with prop.table()

# --- BASE R ---
uniProps <- prop.table( uniTable )
cat("\nUniversity proportions:\n")
print( uniProps )


###############################################################################
# 11) Data manipulation - TIDYVERSE
###############################################################################

# (A) SELECT columns

# --- PACKAGE: dplyr (tidyverse) ---
studDf %>%
  select( studId, uni, coffee )

# (B) SELECT rows (filter)

# --- PACKAGE: dplyr ---
studDf %>%
  filter( uni == "ceu" )

# (C) MUTATE

# --- PACKAGE: dplyr ---
studDf %>%
  mutate(
    coffeeDouble = coffee * 2,
    uniUpper     = toupper(uni)
  )

# (D) TRANSMUTE

# --- PACKAGE: dplyr ---
studDf %>%
  transmute(
    id          = studId,
    coffeeScore = coffee * 10
  )

# (E) GROUP summaries

# --- PACKAGE: dplyr ---
studDf %>%
  group_by( uni ) %>%
  summarise(
    n        = n(),
    avgCoffee = mean(coffee),
    avgExam  = mean(examScore)
  )


###############################################################################
# 11F) Comparison: FOR LOOP vs TIDYVERSE
###############################################################################

# Goal: Calculate mean examScore for CEU students

# --- FOR LOOP VERSION (verbose, educational) ---
total <- 0
count <- 0

for ( i in 1:nrow(studDf) ) {

  # Check if this row is CEU
  if ( studDf$uni[i] == "ceu" ) {

    # Add to total
    total <- total + studDf$examScore[i]
    count <- count + 1

    cat("Found CEU student", i, "score:", studDf$examScore[i], "\n")

  }

}

meanLoop <- total / count
cat("\nFor-loop result:", meanLoop, "\n")

# --- TIDYVERSE VERSION (concise) ---
meanTidy <- studDf %>%
  filter( uni == "ceu" ) %>%
  summarise( mean = mean(examScore) ) %>%
  pull( mean )

cat("Tidyverse result:", meanTidy, "\n")

# --- BASE R ONE-LINER ---
meanBase <- mean( studDf$examScore[ studDf$uni == "ceu" ] )
cat("Base R result:", meanBase, "\n")


###############################################################################
# 12) Combine data
###############################################################################

# (A) ADD column with ifelse
# TASK: Add district (CEU = 10, others = 1)

# --- BASE R ---
studDf$district <- ifelse(
  studDf$uni == "ceu",
  10,
  1
)

cat("With district column:\n")
print( studDf[ , c("studId", "uni", "district") ] )

# (B) SAMPLING FUNCTIONS
# TASK: Create sampleStudents() function

# --- BASE R (step by step, well spaced) ---
sampleStudents <- function( df, n, replace = TRUE ) {

  # How many rows in original?
  nRows <- nrow( df )

  # Generate random row indices
  idx <- sample(
    x       = 1:nRows,
    size    = n,
    replace = replace
  )

  # Debug: show what we sampled
  cat("Sampled indices:", idx, "\n")

  # Extract those rows
  result <- df[ idx , ]

  return( result )

}

# TASK: Sample 3 students WITH replacement
set.seed(42)  # For reproducibility

sampledWith <- sampleStudents( studDf, n = 3, replace = TRUE )
cat("\nSampled WITH replacement:\n")
print( sampledWith )

# TASK: Sample 4 students WITHOUT replacement
sampledNoRep <- sampleStudents( studDf, n = 4, replace = FALSE )
cat("\nSampled WITHOUT replacement:\n")
print( sampledNoRep )

# (C) COMBINE DATASETS
# TASK: Bind with rbind()

# --- BASE R ---
combinedBase <- rbind( studDf, sampledWith )
cat("\nCombined (rbind):\n")
cat("Original rows:", nrow(studDf), "\n")
cat("Sampled rows:", nrow(sampledWith), "\n")
cat("Combined rows:", nrow(combinedBase), "\n")

# --- PACKAGE: dplyr ---
combinedTidy <- bind_rows( studDf, sampledWith )

# (D) COMPARE & FILTER
# TASK: Examine dimensions

cat("\ndim(studDf):", dim(studDf), "\n")
cat("dim(combinedBase):", dim(combinedBase), "\n")

# TASK: Use %in% to filter sampled students

# --- BASE R ---
targetUnis <- c("ceu", "uv")

fromTargets <- sampledWith[ sampledWith$uni %in% targetUnis , ]
cat("\nSampled students from CEU or UV:\n")
print( fromTargets )


###############################################################################
# 13) Visualization
###############################################################################

# TASK: Scatter plot colored by category

# --- PACKAGE: ggplot2 ---
ggplot( studDf, aes(x = coffee, y = examScore, color = uni) ) +
  geom_point( size = 3 ) +
  labs(
    title = "Coffee vs Exam Score by University",
    x     = "Coffee Cups/Day",
    y     = "Exam Score",
    color = "University"
  )

# TASK: Scatter plot with regression line

# --- PACKAGE: ggplot2 ---
ggplot( studDf, aes(x = studyHrs, y = examScore) ) +
  geom_point( size = 3, color = "steelblue" ) +
  geom_smooth( method = "lm", formula = y ~ x, se = FALSE, color = "red" ) +
  labs(
    title = "Study Hours vs Exam Score",
    x     = "Study Hours/Week",
    y     = "Exam Score"
  )

# --- BASE R version ---
plot(
  x    = studDf$studyHrs,
  y    = studDf$examScore,
  main = "Study Hours vs Exam Score",
  xlab = "Study Hours/Week",
  ylab = "Exam Score",
  pch  = 16,
  col  = "steelblue"
)
abline( lm(examScore ~ studyHrs, data = studDf), col = "red" )


###############################################################################
# 14) Analysis
###############################################################################

# TASK: Calculate correlation

# --- BASE R ---
corVal <- cor(
  studDf$coffee,
  studDf$examScore,
  use = "complete.obs"
)
cat("Correlation (coffee, examScore):", corVal, "\n")

# Multiple correlations
corMat <- cor(
  studDf[ , c("coffee", "studyHrs", "examScore") ],
  use = "complete.obs"
)
cat("\nCorrelation matrix:\n")
print( round(corMat, 3) )

# TASK: t-test comparing groups

# --- BASE R ---
tResult <- t.test( examScore ~ highCoffee, data = studDf )
cat("\nt-test result:\n")
print( tResult )

# TASK: OLS regression with two predictors

# --- BASE R (step by step) ---
# Model: examScore = b0 + b1*coffee + b2*studyHrs

mod1 <- lm( examScore ~ coffee + studyHrs, data = studDf )

cat("\nRegression summary:\n")
print( summary(mod1) )

# TASK: Add categorical predictor

mod2 <- lm( examScore ~ coffee + studyHrs + uni, data = studDf )

cat("\nWith university:\n")
print( summary(mod2) )

# TASK: Display with texreg (if available)
if ( requireNamespace("texreg", quietly = TRUE) ) {
  texreg::screenreg( list(mod1, mod2) )
}

# TASK: Display with stargazer (if available)
if ( requireNamespace("stargazer", quietly = TRUE) ) {
  stargazer::stargazer( mod1, mod2, type = "text" )
}


###############################################################################
# 15) Custom Functions
###############################################################################

# (A) MEAN
# TASK: Write myMean()

# --- BASE R (verbose, educational) ---
myMean <- function( x ) {

  # Remove NAs first
  x <- x[ !is.na(x) ]

  # Sum all values
  total <- sum( x )

  # Count how many values
  n <- length( x )

  # Calculate mean
  result <- total / n

  # Debug output
  cat("Sum:", total, "Count:", n, "Mean:", result, "\n")

  return( result )

}

# Test it
testVec <- c(10, 20, 30, 40, 50)
myMean( testVec )  # Should be 30
mean( testVec )    # R's version

# (B) VARIANCE
# TASK: Write myVar()

# --- BASE R (step by step) ---
myVar <- function( x ) {

  # Remove NAs
  x <- x[ !is.na(x) ]

  # Step 1: Get the mean
  m <- myMean( x )

  # Step 2: Calculate deviations from mean
  devs <- x - m
  cat("Deviations:", devs, "\n")

  # Step 3: Square the deviations
  sqDevs <- devs ^ 2
  cat("Squared devs:", sqDevs, "\n")

  # Step 4: Average of squared deviations
  n      <- length( x )
  result <- sum( sqDevs ) / n

  cat("Variance:", result, "\n")

  return( result )

}

# Test it
myVar( testVec )

# (C) STANDARD DEVIATION
# TASK: Write mySd()

# --- BASE R ---
mySd <- function( x ) {

  # SD = square root of variance
  v <- myVar( x )

  result <- sqrt( v )

  cat("SD:", result, "\n")

  return( result )

}

# Test it
mySd( testVec )

# (D) NORMAL DISTRIBUTION
# TASK: Write myRnorm() using CLT

# --- BASE R (step by step, educational) ---
myRnorm <- function( n, mean = 0, sd = 1 ) {

  # Container for results
  samples <- numeric( n )

  for ( i in 1:n ) {

    # Step 1: Generate 12 uniform random numbers
    uniforms <- runif( 12 )

    # Step 2: Sum them
    sumVal <- sum( uniforms )

    # Step 3: Subtract 6 to center at 0
    # Why 12? Uniform(0,1) has mean=0.5, var=1/12
    # Sum of 12: mean=6, var=1
    # Subtract 6: mean=0, var=1 -> Standard Normal!
    zScore <- sumVal - 6

    # Step 4: Scale and shift
    # result = z * sd + mean
    samples[i] <- zScore * sd + mean

  }

  return( samples )

}

# TASK: Test myRnorm()
set.seed( 123 )

mySamples <- myRnorm( n = 1000, mean = 50, sd = 10 )

cat("\nGenerated 1000 samples:\n")
cat("Mean:", myMean(mySamples), "(expected: 50)\n")
cat("SD:", mySd(mySamples), "(expected: 10)\n")

# Histogram
hist(
  mySamples,
  breaks = 30,
  main   = "Custom Normal Distribution",
  xlab   = "Value",
  col    = "lightblue"
)

# TASK: Simulate sampling distribution

# --- BASE R (step by step) ---
nSims      <- 1000
sampleSize <- 30
sampleMeans <- numeric( nSims )

for ( i in 1:nSims ) {

  # Take a sample of size 30
  samp <- myRnorm( n = sampleSize, mean = 100, sd = 15 )

  # Calculate its mean
  sampleMeans[i] <- mean( samp )

}

# Plot the sampling distribution
hist(
  sampleMeans,
  breaks = 30,
  main   = "Sampling Distribution of Means",
  xlab   = "Sample Mean",
  col    = "lightgreen"
)

# The sampling distribution should be normal with:
# - Mean = population mean (100)
# - SD = population SD / sqrt(n) = 15 / sqrt(30) ≈ 2.74

cat("\nSampling distribution:\n")
cat("Mean of sample means:", mean(sampleMeans), "(expected: 100)\n")
cat("SD of sample means:", sd(sampleMeans), "(expected:", 15/sqrt(30), ")\n")


###############################################################################
# Extra: Verify against R's functions
###############################################################################

testData <- c(5, 10, 15, 20, 25, 30)

cat("\nComparison with R's functions:\n")
cat("myMean:", myMean(testData), "| mean():", mean(testData), "\n")
cat("mySd:", mySd(testData), "| sd():", sd(testData), "\n")

# Note: R's var() and sd() use n-1 (sample variance)
# Our version uses n (population variance)
# That's why they differ slightly


###############################################################################
###############################################################################
#
#  END OF ANSWER KEY
#
###############################################################################
###############################################################################
