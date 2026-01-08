###############################################################################
###############################################################################
#
#  R SESSION 1 - ANSWER KEY (MIX VERSION)
#  CEU Causality Economics Course
#
#  This file contains complete solutions for mix_template.R
#
#  DATASETS USED:
#  - Star Wars (dplyr::starwars)     -> Sections 0-6
#  - Spotify (moderndive::spotify_by_genre) -> Sections 7-11
#  - Titanic (titanic::titanic_train) -> Sections 12-15
#
#  Each dataset section includes a quick variable reference.
#  For detailed naming conventions, see the cheat sheet files in this folder:
#    - starwars_cheatsheet.R
#    - spotify_cheatsheet.R
#    - titanic_cheatsheet.R
#
#  STYLE NOTES:
#  - camelCase naming (e.g., myVar, popByGenre)
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
library(tidyverse)    # includes dplyr, ggplot2, and starwars data
library(moderndive)   # for spotify_by_genre
library(titanic)      # for titanic_train
library(haven)
library(readxl)
library(writexl)

# TASK: Load datasets
# starwars is automatically available with dplyr
data(spotify_by_genre)  # from moderndive
data(titanic_train)     # from titanic

# Quick check
cat("\nDatasets loaded!\n")
cat("starwars:", nrow(starwars), "rows\n")
cat("spotify_by_genre:", nrow(spotify_by_genre), "rows\n")
cat("titanic_train:", nrow(titanic_train), "rows\n")


###############################################################################
###############################################################################
#  DATASET 1: STAR WARS CHARACTERS (Sections 0-6)
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║  QUICK REFERENCE - Variables used in Sections 0-6:                        ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  name        Character name (e.g., "Luke Skywalker")                      ║
#  ║  height      Height in cm (172 = 172cm)                                   ║
#  ║  mass        Weight in kg (77 = 77kg)                                     ║
#  ║  species     Species name (Human, Droid, Wookiee, etc.)                   ║
#  ║  birth_year  Birth year BBY (41.9 = 41.9 years Before Battle of Yavin)    ║
#  ║  homeworld   Home planet (Tatooine, Naboo, Alderaan, etc.)                ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
###############################################################################
###############################################################################


###############################################################################
# 1) Logging
###############################################################################

# TASK: Print "Hello Star Wars!" using print()
print("Hello Star Wars!")
# Output: [1] "Hello Star Wars!"

# TASK: Print "Hello Star Wars!" using cat() and notice the difference
cat("Hello Star Wars!\n")
# Output: Hello Star Wars!
# NOTE: cat() doesn't show [1] or quotes - cleaner for messages

# TASK: Use cat() to print multiple strings on separate lines
cat("Luke Skywalker\n")
cat("Darth Vader\n")
cat("Yoda\n")

# Or all at once:
cat("Episode 4\nEpisode 5\nEpisode 6\n")

# TASK: Use cat() to print text with custom spacing and line breaks
cat("\n")
cat("===================\n")
cat("  A LONG TIME AGO  \n")
cat("  IN A GALAXY FAR  \n")
cat("     FAR AWAY...   \n")
cat("===================\n")
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

# Another example: convert height from cm to feet
cmToFeet <- function( cm ) {

  feet <- cm / 30.48

  return( feet )

}

cmToFeet( 180 )  # about 5.9 feet
cmToFeet( 66 )   # Yoda's height in feet


###############################################################################
# 4) Data types & objects
###############################################################################

# TASK: Create a numeric variable
myNum <- 42
cat("myNum =", myNum, "\n")

# TASK: Create a character variable
myChar <- "Jedi"
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

# TASK: Convert numeric to character
numToChar <- as.character( 456 )
cat("as.character(456) =", numToChar, "class:", class(numToChar), "\n")

# TASK: Convert numeric to logical
cat("\nNumeric to logical:\n")
cat("as.logical(0)  =", as.logical(0), "\n")
cat("as.logical(1)  =", as.logical(1), "\n")

# TASK: Create factor and examine levels
species <- c("Human", "Droid", "Wookiee", "Human", "Droid")
cat("\nOriginal species:", species, "\n")

specFactor <- factor( species )
cat("Factor:", as.character(specFactor), "\n")
cat("Levels:", levels(specFactor), "\n")

# TASK: Numeric vector to factor, then to character
scores <- c(1, 2, 3, 1, 2, 3)
scoreFactor <- factor( scores )
scoreChar <- as.character( scoreFactor )
cat("\nBack to character:", scoreChar, "\n")

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

cat("a + b  =", a + b, "\n")
cat("a - b  =", a - b, "\n")
cat("a * b  =", a * b, "\n")
cat("a / b  =", a / b, "\n")
cat("a %% b =", a %% b, "\n")
cat("a ^ b  =", a ^ b, "\n")

# TASK: Test logical comparisons
cat("\nLogical comparisons:\n")
cat("a == b :", a == b, "\n")
cat("a != b :", a != b, "\n")
cat("a < b  :", a < b, "\n")
cat("a > b  :", a > b, "\n")

# TASK: Create a vector
myVec <- c(5, 12, 3, 18, 9, 25, 1, 15)
cat("\nmyVec:", myVec, "\n")

# TASK: Logical indexing with conditions
big <- myVec[ myVec > 10 ]
cat("Elements > 10:", big, "\n")

extreme <- myVec[ myVec < 5 | myVec > 15 ]
cat("< 5 OR > 15:", extreme, "\n")

middle <- myVec[ myVec >= 5 & myVec <= 15 ]
cat(">= 5 AND <= 15:", middle, "\n")

# TASK: Negative indexing
cat("\nNegative indexing:\n")
cat("myVec[-1]:", myVec[-1], "\n")

# TASK: Positional indexing
cat("\nPositional indexing:\n")
cat("myVec[c(1,3,5)]:", myVec[c(1,3,5)], "\n")

# TASK: Vector with NAs, calculate mean
naVec <- c(10, NA, 20, NA, 30)
meanGood <- mean( naVec, na.rm = TRUE )
cat("\nmean(naVec, na.rm=TRUE):", meanGood, "\n")

# TASK: Vector length and arithmetic
cat("\nlength(myVec):", length(myVec), "\n")
myVec + 10
myVec * 2

# TASK: Use %in% operator
cat("\n%in% operator:\n")
targets <- c(5, 12, 25)
matched <- myVec[ myVec %in% targets ]
cat("Elements in {5, 12, 25}:", matched, "\n")


###############################################################################
# 6) Dates: as.Date() + basic manipulation
###############################################################################

# TASK: Create date strings in mm/dd/yy format
dateStrs <- c("05/25/77", "05/21/80", "05/25/83")  # Star Wars release dates
cat("Date strings:", dateStrs, "\n")

# TASK: Convert to Date objects
dates1 <- as.Date( dateStrs, format = "%m/%d/%y" )
cat("Converted dates:", as.character(dates1), "\n")

# TASK: Dates in yyyy-mm-dd format
dateStrs2 <- c("1977-05-25", "1980-05-21", "1983-05-25")
dates2 <- as.Date( dateStrs2 )
cat("ISO dates:", as.character(dates2), "\n")

# TASK: Add/subtract days
epIV <- as.Date("1977-05-25")
cat("\nEpisode IV release:", as.character(epIV), "\n")

weekLater <- epIV + 7
cat("One week later:", as.character(weekLater), "\n")

# TASK: Extract year, month, day using format()
cat("\nUsing base R format():\n")
cat("format(epIV, '%Y'):", format(epIV, "%Y"), "\n")
cat("format(epIV, '%m'):", format(epIV, "%m"), "\n")
cat("format(epIV, '%d'):", format(epIV, "%d"), "\n")


###############################################################################
###############################################################################
#  DATASET 2: SPOTIFY TRACKS (Sections 7-11)
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║  QUICK REFERENCE - Variables used in Sections 7-11:                       ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  track_name      Song name (e.g., "Blinding Lights")                      ║
#  ║  artists         Artist name(s) (e.g., "The Weeknd")                      ║
#  ║  popularity      Popularity score 0-100 (higher = more popular)           ║
#  ║  duration_ms     Duration in milliseconds (180000 = 3 minutes)            ║
#  ║  energy          Energy score 0-1 (1 = high energy)                       ║
#  ║  danceability    Danceability score 0-1 (1 = very danceable)              ║
#  ║  valence         Positiveness 0-1 (1 = happy/cheerful)                    ║
#  ║  track_genre     Genre: country, deep-house, dubstep, hip-hop, metal, rock║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
###############################################################################
###############################################################################


###############################################################################
# 7) Exploring the Spotify data
###############################################################################

# Create short reference
spot <- spotify_by_genre

# TASK: First few rows
cat("\nhead(spot):\n")
print( head(spot) )

# TASK: Structure
cat("\nstr(spot):\n")
str( spot )

# TASK: Summary
cat("\nsummary(spot):\n")
print( summary(spot[, c("popularity", "danceability", "energy", "valence")]) )

# TASK: Dimensions
cat("\ndim(spot):", dim(spot), "\n")

# TASK: How many tracks?
nTracks <- nrow( spot )
cat("Total tracks:", nTracks, "\n")

# TASK: Unique genres
cat("\nUnique genres:", unique(spot$track_genre), "\n")

# TASK: Missing values in popularity
naMissing <- sum( is.na(spot$popularity) )
cat("Missing popularity values:", naMissing, "\n")

# TASK: Most popular track
maxPop <- which.max( spot$popularity )
cat("\nMost popular track:\n")
cat("  Name:", spot$track_name[maxPop], "\n")
cat("  Artist:", spot$artists[maxPop], "\n")
cat("  Popularity:", spot$popularity[maxPop], "\n")


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
write.csv( spot, "data/spotify.csv", row.names = FALSE )
cat("Saved to data/spotify.csv\n")

# TASK: Read CSV back

# --- BASE R ---
dfCsv <- read.csv( "data/spotify.csv" )
cat("Read back:\n")
print( head(dfCsv, 3) )

# --- PACKAGE: readr (tidyverse) ---
dfCsvTidy <- read_csv( "data/spotify.csv" )

# TASK: Export as TSV

# --- BASE R ---
write.table( spot, "data/spotify.tsv", sep = "\t", row.names = FALSE )
cat("\nSaved TSV\n")

# TASK: Read TSV
dfTsv <- read.table( "data/spotify.tsv", sep = "\t", header = TRUE )

# TASK: Export as Excel
write_xlsx( spot, "data/spotify.xlsx" )
cat("Saved Excel\n")

# TASK: Read Excel
dfXl <- read_excel( "data/spotify.xlsx" )

# TASK: Export/import SPSS
write_sav( spot, "data/spotify.sav" )
dfSav <- read_sav( "data/spotify.sav" )

# TASK: Export/import Stata
write_dta( spot, "data/spotify.dta" )
dfDta <- read_dta( "data/spotify.dta" )


###############################################################################
# 10) Data manipulation - BASE R
###############################################################################

# (A) SELECT columns
# TASK: Select specific columns

# --- BASE R (step by step) ---
cols <- c("track_name", "artists", "popularity", "danceability", "energy")

dfSubset <- spot[ , cols ]

cat("Selected columns:\n")
print( head(dfSubset) )

# (B) SELECT rows
# TASK: Filter to rock genre

# --- BASE R (very explicit) ---

# Step 1: Create logical condition
isRock <- spot$track_genre == "rock"
cat("\nisRock (first 10):", head(isRock, 10), "\n")

# Step 2: Use it to filter
rockTracks <- spot[ isRock , ]
cat("\nRock tracks:", nrow(rockTracks), "\n")

# (C) ADD or MODIFY columns
# TASK: Add duration_min column

# --- BASE R ---
spot$durMin <- spot$duration_ms / 60000

cat("\nWith durMin column:\n")
print( head(spot[ , c("track_name", "duration_ms", "durMin") ], 5) )

# TASK: Add energy_level column

# --- BASE R ---
spot$nrgLevel <- ifelse(
  spot$energy > 0.7,
  "High",
  "Low"
)

cat("\nEnergy levels:\n")
print( table(spot$nrgLevel) )

# (D) TRANSMUTE - select and derive new columns

# --- BASE R ---
newDf <- data.frame(
  track    = spot$track_name,
  popPct   = spot$popularity,
  mood     = ifelse(spot$valence > 0.5, "Happy", "Sad")
)

cat("\nTransmuted data frame:\n")
print( head(newDf) )

# (E) GROUP summaries
# TASK: Mean popularity by genre

# --- BASE R ---
popByGenre <- aggregate(
  popularity ~ track_genre,
  data = spot,
  FUN  = mean
)

cat("\nMean popularity by genre:\n")
print( popByGenre )

# TASK: Frequency tables

# --- BASE R ---
genreTable <- table( spot$track_genre )
cat("\nGenre counts:\n")
print( genreTable )

# TASK: Proportions
genreProps <- prop.table( genreTable )
cat("\nGenre proportions:\n")
print( round(genreProps, 3) )


###############################################################################
# 11) Data manipulation - TIDYVERSE
###############################################################################

# (A) SELECT columns

# --- PACKAGE: dplyr ---
spot %>%
  select( track_name, artists, popularity, energy ) %>%
  head()

# (B) SELECT rows (filter)

# --- PACKAGE: dplyr ---
spot %>%
  filter( popularity > 70 ) %>%
  head()

# (C) MUTATE

# --- PACKAGE: dplyr ---
spot %>%
  mutate(
    durMin   = duration_ms / 60000,
    nrgLevel = ifelse(energy > 0.7, "High", "Low")
  ) %>%
  select(track_name, durMin, nrgLevel) %>%
  head()

# (D) TRANSMUTE

# --- PACKAGE: dplyr ---
spot %>%
  transmute(
    track  = track_name,
    popPct = popularity
  ) %>%
  head()

# (E) GROUP summaries

# --- PACKAGE: dplyr ---
spot %>%
  group_by( track_genre ) %>%
  summarise(
    n       = n(),
    avgPop  = mean(popularity),
    avgNrg  = mean(energy)
  )


###############################################################################
# 11F) Comparison: FOR LOOP vs TIDYVERSE
###############################################################################

# Goal: Calculate mean energy for each genre

# --- FOR LOOP VERSION (verbose, educational) ---
cat("\n--- FOR LOOP ---\n")

genres <- unique( spot$track_genre )

for ( g in genres ) {

  # Filter to this genre
  genreData <- spot[ spot$track_genre == g , ]

  # Calculate mean energy
  avgNrg <- mean( genreData$energy )

  # Print
  cat("Genre:", g, "- mean energy:", round(avgNrg, 3), "\n")

}

# --- TIDYVERSE VERSION (concise) ---
cat("\n--- TIDYVERSE ---\n")

nrgByGenre <- spot %>%
  group_by( track_genre ) %>%
  summarise( avgNrg = mean(energy) )

print( nrgByGenre )

# --- BASE R aggregate ---
cat("\n--- BASE R aggregate ---\n")
print( aggregate(energy ~ track_genre, data = spot, FUN = mean) )


###############################################################################
###############################################################################
#  DATASET 3: TITANIC PASSENGERS (Sections 12-15)
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║  QUICK REFERENCE - Variables used in Sections 12-15:                      ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  PassengerId  Unique passenger ID (1-891)                                 ║
#  ║  Survived     Survival (0 = No, 1 = Yes)                                  ║
#  ║  Pclass       Ticket class (1 = 1st, 2 = 2nd, 3 = 3rd)                    ║
#  ║  Name         Passenger name                                              ║
#  ║  Sex          Sex (male, female)                                          ║
#  ║  Age          Age in years                                                ║
#  ║  SibSp        # of siblings/spouses aboard                                ║
#  ║  Parch        # of parents/children aboard                                ║
#  ║  Fare         Passenger fare (in pounds)                                  ║
#  ║  Embarked     Port (C=Cherbourg, Q=Queenstown, S=Southampton)             ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
###############################################################################
###############################################################################


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
myMean( testVec )
mean( testVec )

# (B) VARIANCE

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
    zScore <- sumVal - 6

    # Step 4: Scale and shift
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


###############################################################################
###############################################################################
#
#  END OF MIX ANSWER KEY
#
###############################################################################
###############################################################################

