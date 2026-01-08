###############################################################################
###############################################################################
#
#  R SESSION 1 - INTRODUCTION TO R & RSTUDIO (MIX VERSION)
#  CEU Causality Economics Course
#
###############################################################################
###############################################################################
#
#  NOTE: This template covers more material than we can complete in one session.
#  Any sections we don't finish are for you to complete on your own.
#  Solutions are provided in mix_answers.R
#
#  This version uses THREE different datasets across sections:
#    - Star Wars characters  (dplyr::starwars)     -> Sections 0-6
#    - Spotify tracks        (moderndive::spotify_by_genre) -> Sections 7-11
#    - Titanic passengers    (titanic::titanic_train) -> Sections 12-15
#
#  Each dataset section includes a quick variable reference.
#  For detailed naming conventions, see the cheat sheet files in this folder:
#    - starwars_cheatsheet.R
#    - spotify_cheatsheet.R
#    - titanic_cheatsheet.R
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
#  Section 7:  Exploring Spotify data   ~15 min
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
#       - tidyverse (for data manipulation, visualization, and starwars data)
#       - moderndive (for Spotify dataset)
#       - titanic (for Titanic dataset)
#       - haven (for SPSS and Stata files)
#       - readxl (for Excel files)
#       - writexl (for writing Excel files)

# TASK: Load the datasets we'll use:
#       - starwars is automatically available with dplyr/tidyverse
#       - data(spotify_by_genre) from moderndive
#       - data(titanic_train) from titanic


###############################################################################
###############################################################################
#
#  DATASET 1: STAR WARS CHARACTERS (Sections 0-6)
#  ==================================================
#
#  Source: dplyr::starwars (comes with tidyverse)
#  87 characters from Star Wars films, 14 variables
#
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║  QUICK REFERENCE - Variables you'll use in Sections 0-6:                  ║
#  ╠═══════════════════════════════════════════════════════════════════════════╣
#  ║  name        Character name (e.g., "Luke Skywalker")                      ║
#  ║  height      Height in cm (172 = 172cm)                                   ║
#  ║  mass        Weight in kg (77 = 77kg)                                     ║
#  ║  species     Species name (Human, Droid, Wookiee, etc.)                   ║
#  ║  birth_year  Birth year BBY (41.9 = 41.9 years Before Battle of Yavin)    ║
#  ║  homeworld   Home planet (Tatooine, Naboo, Alderaan, etc.)                ║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
#  Other columns: hair_color, skin_color, eye_color, sex, gender,
#                 films (list), vehicles (list), starships (list)
#
###############################################################################
###############################################################################


###############################################################################
# 1) Logging
###############################################################################

# TASK: Print "Hello Star Wars!" using print()

# TASK: Print "Hello Star Wars!" using cat() and notice the difference

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
# 3) Functions (simple + explicit return())
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

# TASK: Create a vector of date strings in format "mm/dd/yy"

# TASK: Convert to Date objects using as.Date() with the correct format parameter
#       (hint: check ?as.Date for format codes like %m, %d, %y)

# TASK: Do the same for dates in "yyyy-mm-dd" format

# TASK: Add/subtract days from a date

# TASK: Extract year, month, and day components using format()
#       (hint: format(myDate, "%Y") for year, "%m" for month, "%d" for day)


###############################################################################
###############################################################################
#
#  DATASET 2: SPOTIFY TRACKS (Sections 7-11)
#  ==================================================
#
#  Source: moderndive::spotify_by_genre
#  6,000 tracks from Spotify, 21 variables
#
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║  QUICK REFERENCE - Variables you'll use in Sections 7-11:                 ║
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
#
#  Other columns: track_id, album_name, explicit, key, loudness, mode,
#                 speechiness, acousticness, instrumentalness, liveness,
#                 tempo, time_signature, popular_or_not
#
###############################################################################
###############################################################################


###############################################################################
# 7) Exploring the Spotify data (instead of creating data frames)
###############################################################################

# NOTE: We'll use spotify_by_genre which is loaded from moderndive package

# TASK: Look at the first few rows using head()

# TASK: Examine structure with str()

# TASK: Get summary statistics with summary()

# TASK: Check dimensions with dim()

# TASK: How many tracks total? (hint: nrow())

# TASK: What are the unique genres? (hint: unique() on track_genre column)

# TASK: How many missing values in popularity? (hint: sum() with is.na())

# TASK: What is the most popular track? (hint: filter or which.max())


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
# 9) Exporting + importing the Spotify dataset (CSV, TXT, XLSX, SAV, DTA)
###############################################################################

# TASK: Export spotify_by_genre as CSV using write.csv()
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
# TASK: Select track_name, artists, popularity, danceability, energy columns

# (B) SELECT rows
# TASK: Filter to only "rock" genre tracks (track_genre == "rock")

# (C) ADD or MODIFY columns
# TASK: Add a duration_min column (duration_ms / 60000)
# TASK: Add an energy_level column using ifelse() ("High" if energy > 0.7)

# (D) TRANSMUTE (select and modify columns, keep only selected ones)
# TASK: Create a new data frame with track_name and popularity_pct (popularity as %)
# TASK: Use ifelse() to create a mood column ("Happy" if valence > 0.5)

# (E) GROUP summaries
# TASK: Calculate mean popularity by genre using aggregate()
# TASK: Create frequency tables of track_genre using table()
# TASK: Calculate proportions using prop.table()


###############################################################################
# 11) Data manipulation - TIDYVERSE (%>%) in parallel
###############################################################################

# (A) SELECT columns (tidyverse)
# TASK: Use select() to choose track_name, artists, popularity, energy

# (B) SELECT rows (tidyverse)
# TASK: Use filter() to keep only popular tracks (popularity > 70)

# (C) MUTATE (tidyverse)
# TASK: Use mutate() to add duration_min and energy_level columns

# (D) TRANSMUTE (tidyverse)
# TASK: Use transmute() to create a data frame with only selected columns

# (E) GROUP summaries (tidyverse)
# TASK: Use group_by() and summarise() to calculate mean popularity by genre
#       (hint: use n() to count observations)


###############################################################################
# 11F) Comparison: FOR LOOP vs TIDYVERSE (same result, different approach)
###############################################################################

# TASK: Write a for-loop to calculate mean energy for each genre
#       (hint: iterate through unique genres, filter and calculate for each)

# TASK: Accomplish the same task using tidyverse with group_by() and summarise()

# TASK: Compare the two results and note which approach is more readable


###############################################################################
###############################################################################
#
#  DATASET 3: TITANIC PASSENGERS (Sections 12-15)
#  ==================================================
#
#  Source: titanic::titanic_train
#  891 passengers from RMS Titanic, 12 variables
#
#  ╔═══════════════════════════════════════════════════════════════════════════╗
#  ║  QUICK REFERENCE - Variables you'll use in Sections 12-15:                ║
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
#  ║  Embarked     Port of embarkation (C=Cherbourg, Q=Queenstown, S=Southampton)║
#  ╚═══════════════════════════════════════════════════════════════════════════╝
#
#  Other columns: Ticket, Cabin
#
###############################################################################
###############################################################################


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
#  END OF MIX TEMPLATE
#
#  Any sections we didn't cover in class are for you to complete on your own.
#  Check mix_answers.R for complete solutions.
#
###############################################################################
###############################################################################

