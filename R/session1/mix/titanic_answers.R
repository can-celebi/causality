###############################################################################
###############################################################################
#
#  R SESSION 1 - ANSWER KEY (TITANIC VERSION)
#  CEU Causality Economics Course
#
#  This file contains complete solutions for titanic_template.R
#
#  STYLE NOTES:
#  - camelCase naming (e.g., myVar, fareHigh)
#  - Short but intuitive names
#  - Lots of spacing for visibility (especially in base R)
#  - Step-by-step approach for complex operations
#  - Both BASE R and PACKAGE versions where applicable
#
#  See titanic_cheatsheet.R for variable naming conventions.
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
library(titanic)
library(haven)
library(readxl)
library(writexl)

# TASK: Load the titanic_train dataset
data(titanic_train)

# Quick peek
cat("\nTitanic data loaded!\n")
cat("Rows:", nrow(titanic_train), "\n")
cat("Columns:", ncol(titanic_train), "\n")


###############################################################################
# 1) Logging
###############################################################################

# TASK: Print "Hello Titanic!" using print()
print("Hello Titanic!")
# Output: [1] "Hello Titanic!"

# TASK: Print "Hello Titanic!" using cat() and notice the difference
cat("Hello Titanic!\n")
# Output: Hello Titanic!
# NOTE: cat() doesn't show [1] or quotes - cleaner for messages

# TASK: Use cat() to print multiple strings on separate lines
cat("First class\n")
cat("Second class\n")
cat("Third class\n")

# Or all at once:
cat("1st\n2nd\n3rd\n")

# TASK: Use cat() to print text with custom spacing and line breaks
cat("\n")
cat("==================\n")
cat("  R.M.S. TITANIC  \n")
cat("==================\n")
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
# 3) Functions 
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
pclasses <- c(1, 2, 3, 1, 2, 3, 1)
cat("\nOriginal classes:", pclasses, "\n")

classFactor <- factor( pclasses )
cat("Factor:", as.character(classFactor), "\n")
cat("Levels:", levels(classFactor), "\n")

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

# NOTE: Titanic departed April 10, 1912, sank April 15, 1912

# TASK: Create date strings in mm/dd/yy format
dateStrs <- c("04/10/12", "04/15/12", "04/18/12")
cat("Date strings:", dateStrs, "\n")

# TASK: Convert to Date objects
# Format codes: %m = month, %d = day, %y = 2-digit year, %Y = 4-digit year

# --- BASE R ---
dates1 <- as.Date( dateStrs, format = "%m/%d/%y" )
cat("Converted dates:", as.character(dates1), "\n")
# Note: 2-digit year interprets as 2012, not 1912!

# For 1912, use 4-digit year:
dateStrs2 <- c("1912-04-10", "1912-04-15", "1912-04-18")
dates2 <- as.Date( dateStrs2 )  # No format needed for ISO format
cat("ISO dates:", as.character(dates2), "\n")

# TASK: Add/subtract days
departure <- as.Date("1912-04-10")
cat("\nDeparture:", as.character(departure), "\n")

sinking <- departure + 5
cat("Sinking (departure + 5):", as.character(sinking), "\n")

rescue <- departure + 8
cat("Rescue (departure + 8):", as.character(rescue), "\n")

daysBefore <- departure - 7
cat("Week before:", as.character(daysBefore), "\n")

# TASK: Extract year, month, day using format() (BASE R - no lubridate)
myDate <- as.Date("1912-04-15")

cat("\nUsing base R format():\n")
cat("format(myDate, '%Y'):", format(myDate, "%Y"), "\n")  # Year
cat("format(myDate, '%m'):", format(myDate, "%m"), "\n")  # Month
cat("format(myDate, '%d'):", format(myDate, "%d"), "\n")  # Day
cat("format(myDate, '%B'):", format(myDate, "%B"), "\n")  # Month name


###############################################################################
# 7) Exploring the Titanic data
###############################################################################

# TASK: First few rows
cat("\nhead(titanic_train):\n")
print( head(titanic_train) )

# TASK: Structure
cat("\nstr(titanic_train):\n")
str( titanic_train )

# TASK: Summary
cat("\nsummary(titanic_train):\n")
print( summary(titanic_train) )

# TASK: Dimensions
cat("\ndim(titanic_train):", dim(titanic_train), "\n")

# TASK: How many passengers?
nPass <- nrow( titanic_train )
cat("Total passengers:", nPass, "\n")

# TASK: How many survived?
nSurvived <- sum( titanic_train$Survived )
survRate  <- nSurvived / nPass
cat("Survived:", nSurvived, "\n")
cat("Survival rate:", round(survRate * 100, 1), "%\n")

# TASK: Unique embarkation ports
cat("\nUnique Embarked values:", unique(titanic_train$Embarked), "\n")

# TASK: Missing Age values
naMissing <- sum( is.na(titanic_train$Age) )
cat("Missing Age values:", naMissing, "\n")


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
write.csv( titanic_train, "data/titanic.csv", row.names = FALSE )
cat("Saved to data/titanic.csv\n")

# TASK: Read CSV back

# --- BASE R ---
dfCsv <- read.csv( "data/titanic.csv" )
cat("Read back:\n")
print( head(dfCsv, 3) )

# --- PACKAGE: readr (tidyverse) ---
dfCsvTidy <- read_csv( "data/titanic.csv" )
# Note: read_csv is faster and shows column types

# TASK: Export as TSV

# --- BASE R ---
write.table( titanic_train, "data/titanic.tsv", sep = "\t", row.names = FALSE )
cat("\nSaved TSV\n")

# TASK: Read TSV

# --- BASE R ---
dfTsv <- read.table( "data/titanic.tsv", sep = "\t", header = TRUE )

# TASK: Export as Excel

# --- PACKAGE: writexl ---
write_xlsx( titanic_train, "data/titanic.xlsx" )
cat("Saved Excel\n")

# TASK: Read Excel

# --- PACKAGE: readxl ---
dfXl <- read_excel( "data/titanic.xlsx" )

# TASK: Export/import SPSS

# --- PACKAGE: haven ---
write_sav( titanic_train, "data/titanic.sav" )
dfSav <- read_sav( "data/titanic.sav" )

# TASK: Export/import Stata

# --- PACKAGE: haven ---
write_dta( titanic_train, "data/titanic.dta" )
dfDta <- read_dta( "data/titanic.dta" )


###############################################################################
# 10) Data manipulation - BASE R
###############################################################################

# (A) SELECT columns
# TASK: Select specific columns

# --- BASE R (step by step) ---
cols <- c("PassengerId", "Survived", "Pclass", "Sex", "Age")

dfSubset <- titanic_train[ , cols ]

cat("Selected columns:\n")
print( head(dfSubset) )

# Alternative: by column index
dfSubset2 <- titanic_train[ , c(1, 2, 3) ]

# (B) SELECT rows
# TASK: Filter to first class passengers

# --- BASE R (very explicit) ---

# Step 1: Create logical condition
isFirstClass <- titanic_train$Pclass == 1
cat("\nisFirstClass (first 10):", head(isFirstClass, 10), "\n")

# Step 2: Use it to filter
firstClass <- titanic_train[ isFirstClass , ]
cat("\nFirst class passengers:", nrow(firstClass), "\n")

# One-liner version:
firstClass <- titanic_train[ titanic_train$Pclass == 1 , ]

# (C) ADD or MODIFY columns
# TASK: Add FamilySize column

# --- BASE R ---
titanic_train$FamilySize <- titanic_train$SibSp + titanic_train$Parch + 1

cat("\nWith FamilySize column:\n")
print( head(titanic_train[ , c("Name", "SibSp", "Parch", "FamilySize") ], 5) )

# TASK: Add AgeGroup column

# --- BASE R ---
titanic_train$AgeGroup <- ifelse(
  titanic_train$Age < 18,
  "Child",
  "Adult"
)

cat("\nAge groups:\n")
print( table(titanic_train$AgeGroup, useNA = "ifany") )

# (D) TRANSMUTE - select and derive new columns
# TASK: Create new df with derived columns

# --- BASE R ---
newDf <- data.frame(
  passId    = titanic_train$PassengerId,
  survived  = titanic_train$Survived,
  fareHigh  = titanic_train$Fare > 50
)

cat("\nTransmuted data frame:\n")
print( head(newDf) )

# TASK: Use ifelse() for FareLevel

# --- BASE R ---
titanic_train$FareLevel <- ifelse(
  titanic_train$Fare > 50,
  "High",
  "Low"
)

cat("\nWith FareLevel:\n")
print( table(titanic_train$FareLevel) )

# (E) GROUP summaries
# TASK: Calculate mean Fare by Pclass using aggregate()

# --- BASE R (step by step) ---
fareByClass <- aggregate(
  Fare ~ Pclass,
  data = titanic_train,
  FUN  = mean
)

cat("\nMean fare by class:\n")
print( fareByClass )

# Multiple aggregations
aggMulti <- aggregate(
  cbind(Fare, Age) ~ Pclass,
  data = titanic_train,
  FUN  = function(x) mean(x, na.rm = TRUE)
)

cat("\nMultiple means by class:\n")
print( aggMulti )

# TASK: Frequency tables with table()

# --- BASE R ---
classTable <- table( titanic_train$Pclass )
cat("\nClass counts:\n")
print( classTable )

# Cross-tabulation
crossTab <- table( titanic_train$Pclass, titanic_train$Survived )
cat("\nPclass x Survived:\n")
print( crossTab )

# TASK: Proportions with prop.table()

# --- BASE R ---
classProps <- prop.table( classTable )
cat("\nClass proportions:\n")
print( classProps )


###############################################################################
# 11) Data manipulation - TIDYVERSE
###############################################################################

# (A) SELECT columns

# --- PACKAGE: dplyr (tidyverse) ---
titanic_train %>%
  select( PassengerId, Survived, Name, Age )

# (B) SELECT rows (filter)

# --- PACKAGE: dplyr ---
titanic_train %>%
  filter( Survived == 1 )

# (C) MUTATE

# --- PACKAGE: dplyr ---
titanic_train %>%
  mutate(
    FamilySize = SibSp + Parch + 1,
    IsChild    = Age < 18
  )

# (D) TRANSMUTE

# --- PACKAGE: dplyr ---
titanic_train %>%
  transmute(
    passId   = PassengerId,
    fareHigh = Fare > 50
  )

# (E) GROUP summaries

# --- PACKAGE: dplyr ---
titanic_train %>%
  group_by( Pclass ) %>%
  summarise(
    n        = n(),
    avgFare  = mean(Fare),
    avgAge   = mean(Age, na.rm = TRUE)
  )


###############################################################################
# 11F) Comparison: FOR LOOP vs TIDYVERSE
###############################################################################

# Goal: Calculate mean Fare for each passenger class

# --- FOR LOOP VERSION (verbose, educational) ---
cat("\n--- FOR LOOP ---\n")

for ( pclass in 1:3 ) {

  # Filter to this class
  classData <- titanic_train[ titanic_train$Pclass == pclass , ]

  # Calculate mean fare
  avgFare <- mean( classData$Fare )

  # Print
  cat("Class", pclass, "mean fare:", round(avgFare, 2), "\n")

}

# --- TIDYVERSE VERSION (concise) ---
cat("\n--- TIDYVERSE ---\n")

fareByClass <- titanic_train %>%
  group_by( Pclass ) %>%
  summarise( avgFare = mean(Fare) )

print( fareByClass )

# --- BASE R ONE-LINER ---
cat("\n--- BASE R aggregate ---\n")
print( aggregate(Fare ~ Pclass, data = titanic_train, FUN = mean) )


###############################################################################
# 12) Combine data
###############################################################################

# (A) ADD column with ifelse
# TASK: Add TicketClass column

# --- BASE R ---
# Nested ifelse for 3 categories
titanic_train$TicketClass <- ifelse(
  titanic_train$Pclass == 1,
  "First",
  ifelse(
    titanic_train$Pclass == 2,
    "Second",
    "Third"
  )
)

cat("With TicketClass column:\n")
print( table(titanic_train$TicketClass) )

# (B) SAMPLING FUNCTIONS
# TASK: Create samplePassengers() function

# --- BASE R (step by step, well spaced) ---
samplePassengers <- function( df, n, replace = TRUE ) {

  # How many rows in original?
  nRows <- nrow( df )

  # Generate random row indices
  idx <- sample(
    x       = 1:nRows,
    size    = n,
    replace = replace
  )

  # Debug: show what we sampled
  cat("Sampled", n, "indices from", nRows, "rows\n")

  # Extract those rows
  result <- df[ idx , ]

  return( result )

}

# TASK: Sample 50 passengers WITH replacement
set.seed(42)  # For reproducibility

sample50 <- samplePassengers( titanic_train, n = 50, replace = TRUE )
cat("\nSampled 50 WITH replacement:\n")
cat("Rows:", nrow(sample50), "\n")

# TASK: Sample 100 passengers WITHOUT replacement
sample100 <- samplePassengers( titanic_train, n = 100, replace = FALSE )
cat("\nSampled 100 WITHOUT replacement:\n")
cat("Rows:", nrow(sample100), "\n")

# (C) COMBINE DATASETS
# TASK: Split by class, then rbind

# --- BASE R ---
class1 <- titanic_train[ titanic_train$Pclass == 1 , ]
class2 <- titanic_train[ titanic_train$Pclass == 2 , ]
class3 <- titanic_train[ titanic_train$Pclass == 3 , ]

cat("\nSplit by class:\n")
cat("Class 1:", nrow(class1), "\n")
cat("Class 2:", nrow(class2), "\n")
cat("Class 3:", nrow(class3), "\n")

combinedBase <- rbind( class1, class2, class3 )
cat("Combined (rbind):", nrow(combinedBase), "\n")

# --- PACKAGE: dplyr ---
combinedTidy <- bind_rows( class1, class2, class3 )

# (D) COMPARE & FILTER
# TASK: Examine dimensions

survivors    <- titanic_train[ titanic_train$Survived == 1 , ]
nonSurvivors <- titanic_train[ titanic_train$Survived == 0 , ]

cat("\ndim(survivors):", dim(survivors), "\n")
cat("dim(nonSurvivors):", dim(nonSurvivors), "\n")

# TASK: Use %in% for embarkation ports

# --- BASE R ---
targetPorts <- c("C", "Q")

fromCQ <- titanic_train[ titanic_train$Embarked %in% targetPorts , ]
cat("\nPassengers from Cherbourg or Queenstown:", nrow(fromCQ), "\n")


###############################################################################
# 13) Visualization
###############################################################################

# TASK: Scatter plot colored by category

# --- PACKAGE: ggplot2 ---
ggplot( titanic_train, aes(x = Age, y = Fare, color = factor(Survived)) ) +
  geom_point( alpha = 0.5 ) +
  labs(
    title = "Age vs Fare by Survival",
    x     = "Age",
    y     = "Fare (Pounds)",
    color = "Survived"
  )

# TASK: Scatter plot with regression line

# --- PACKAGE: ggplot2 ---
ggplot( titanic_train, aes(x = Age, y = Fare) ) +
  geom_point( alpha = 0.5, color = "steelblue" ) +
  geom_smooth( method = "lm", formula = y ~ x, se = FALSE, color = "red" ) +
  labs(
    title = "Age vs Fare with Regression Line",
    x     = "Age",
    y     = "Fare (Pounds)"
  )

# --- BASE R version ---
plot(
  x    = titanic_train$Age,
  y    = titanic_train$Fare,
  main = "Age vs Fare",
  xlab = "Age",
  ylab = "Fare (Pounds)",
  pch  = 16,
  col  = "steelblue"
)
abline( lm(Fare ~ Age, data = titanic_train), col = "red" )


###############################################################################
# 14) Analysis (correlation, t-test, OLS regression)
###############################################################################

# TASK: Calculate correlation

# --- BASE R ---
corVal <- cor(
  titanic_train$Age,
  titanic_train$Fare,
  use = "complete.obs"
)
cat("Correlation (Age, Fare):", round(corVal, 3), "\n")

# Multiple correlations
numCols <- titanic_train[ , c("Age", "Fare", "SibSp", "Parch") ]
corMat <- cor( numCols, use = "complete.obs" )
cat("\nCorrelation matrix:\n")
print( round(corMat, 3) )

# TASK: t-test comparing Fare between survivors and non-survivors

# --- BASE R ---
tResult <- t.test( Fare ~ Survived, data = titanic_train )
cat("\nt-test result:\n")
print( tResult )

# TASK: OLS regression with two predictors
# Model: Fare ~ Age + Pclass

# --- BASE R (step by step) ---
mod1 <- lm( Fare ~ Age + Pclass, data = titanic_train )

cat("\nRegression summary:\n")
print( summary(mod1) )

# TASK: Add categorical predictor (Sex)

mod2 <- lm( Fare ~ Age + Pclass + Sex, data = titanic_train )

cat("\nWith Sex:\n")
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
  m <- sum(x) / length(x)

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

  # Remove NAs
  x <- x[ !is.na(x) ]

  # SD = square root of variance
  m      <- sum(x) / length(x)
  sqDevs <- (x - m) ^ 2
  v      <- sum(sqDevs) / length(x)

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
cat("Mean:", mean(mySamples), "(expected: 50)\n")
cat("SD:", sd(mySamples), "(expected: 10)\n")

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
# - SD = population SD / sqrt(n) = 15 / sqrt(30) ~ 2.74

cat("\nSampling distribution:\n")
cat("Mean of sample means:", mean(sampleMeans), "(expected: 100)\n")
cat("SD of sample means:", sd(sampleMeans), "(expected:", 15/sqrt(30), ")\n")


###############################################################################
# Extra: Verify against R's functions
###############################################################################

testData <- c(5, 10, 15, 20, 25, 30)

cat("\nComparison with R's functions:\n")
cat("myMean:", sum(testData)/length(testData), "| mean():", mean(testData), "\n")
cat("mySd:", mySd(testData), "| sd():", sd(testData), "\n")

# Note: R's var() and sd() use n-1 (sample variance)
# Our version uses n (population variance)
# That's why they differ slightly


###############################################################################
###############################################################################
#
#  END OF TITANIC ANSWER KEY
#
###############################################################################
###############################################################################

