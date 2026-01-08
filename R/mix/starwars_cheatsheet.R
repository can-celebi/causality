###############################################################################
###############################################################################
#
#  STAR WARS - VARIABLE NAMING CHEAT SHEET
#  CEU Causality Economics Course
#
#  This file documents the naming conventions used in mix_answers.R
#  for Sections 0-6 (Star Wars characters dataset)
#  Style: camelCase, short, intuitive
#
###############################################################################
###############################################################################


###############################################################################
# DATASET OVERVIEW: dplyr::starwars
###############################################################################
#
# Source: dplyr package (comes with tidyverse)
# Rows: 87 Star Wars characters
# Columns: 14 variables
#
# ORIGINAL COLUMN NAMES:
#   name, height, mass, hair_color, skin_color, eye_color,
#   birth_year, sex, gender, homeworld, species, films, vehicles, starships
#
###############################################################################


###############################################################################
# NAMING CONVENTION: camelCase
###############################################################################
#
# All variable names use camelCase:
#   - First word lowercase
#   - Subsequent words capitalized
#   - No underscores or dots
#
# Examples:
#   myNum       (not my_num, not my.num)
#   birthYr     (not birth_yr)
#   hairCol     (not hair_col)
#
###############################################################################


###############################################################################
# DATASET COLUMN ABBREVIATIONS
###############################################################################
#
# Full Name       Short Name    Type    Description
# -------------   ----------    ----    ------------------------------------
# (dataset)       sw            tibble  Reference to starwars dataset
# name            name          chr     Character name (keep as-is)
# height          ht            int     Height in centimeters
# mass            wt            dbl     Weight in kilograms
# hair_color      hairCol       chr     Hair color
# skin_color      skinCol       chr     Skin color
# eye_color       eyeCol        chr     Eye color
# birth_year      birthYr       dbl     Birth year (BBY = Before Battle of Yavin)
# sex             sex           chr     Biological sex (keep as-is)
# gender          gender        chr     Gender (keep as-is)
# homeworld       home          chr     Home planet name
# species         spec          chr     Species name
# films           films         list    List of films appeared in (keep as-is)
# vehicles        vehicles      list    List of vehicles piloted (keep as-is)
# starships       starships     list    List of starships piloted (keep as-is)
#
###############################################################################


###############################################################################
# GENERAL VARIABLES (Sections 1-6)
###############################################################################

# --- SCALARS ---
# myNum        numeric value
# myChar       character/string value
# myBool       logical TRUE/FALSE
# myNull       NULL value
# myNa         NA value
# a, b         simple numeric variables for arithmetic
# i            loop iterator
# n            count/number of items
# total        running sum
# result       general result variable

# --- VECTORS ---
# myVec        generic numeric vector
# myNums       sequence of numbers (1:5, 1:10, etc.)
# naVec        vector containing NAs
# testVec      test data vector
# species      vector of species names (before factoring)
# scores       vector of numeric scores
# dateStrs     vector of date strings
# dates1       Date objects (first format)
# dates2       Date objects (second format)

# --- TYPE CONVERSIONS ---
# charNum      character that looks like number ("123")
# numVal       result of as.numeric()
# numToChar    result of as.character()
# specFactor   factor version of species
# scoreFactor  factor version of scores
# scoreChar    character from factor

# --- LOGICAL CONDITIONS ---
# big          elements > some threshold
# extreme      elements < low OR > high
# middle       elements >= low AND <= high
# targets      target values for filtering
# matched      result of %in% matching
# dirExists    TRUE if directory exists


###############################################################################
# STAR WARS SPECIFIC VARIABLES
###############################################################################

# --- DATE EXAMPLES (Section 6) ---
# dateStrs     Star Wars release dates as strings
# dates1       Dates in mm/dd/yy format
# dates2       Dates in yyyy-mm-dd format
# epIV         Episode IV release date (1977-05-25)
# weekLater    Date one week after epIV


###############################################################################
# FUNCTION NAMES (Section 3)
###############################################################################

# doubleIt     function that doubles input value
# cmToFeet     function that converts cm to feet
# result       return value inside function


###############################################################################
# PREFIX CONVENTIONS
###############################################################################

# is...        logical condition (isHuman)
# n...         count (nRows, nChars)
# my...        custom/user-created (myMean, myVar, myVec, myNum, myChar)
# ...Val       single value (numVal)
# ...Factor    factor version (specFactor, scoreFactor)

# --- SUFFIX CONVENTIONS ---
# ...Char      character version (scoreChar, numToChar)
# ...Col       color-related (hairCol, skinCol, eyeCol)
# ...Yr        year-related (birthYr)


###############################################################################
# QUICK REFERENCE TABLE
###############################################################################
#
# Pattern              Example              Meaning
# ------------------   ------------------   -----------------------------------
# single lowercase     a, b, i, n, x        temporary/loop/simple variables
# camelCase            myNum, birthYr       most variables
# my + Type            myNum, myChar        user-created simple variable
# my + Function        myMean, myVar        custom function (Section 15)
# ...Col               hairCol, eyeCol      color columns
# ...Yr                birthYr              year columns
# ...Factor            specFactor           factor version
#
###############################################################################


###############################################################################
###############################################################################
#
#  END OF STAR WARS CHEAT SHEET
#
###############################################################################
###############################################################################
