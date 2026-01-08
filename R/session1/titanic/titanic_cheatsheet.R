###############################################################################
###############################################################################
#
#  TITANIC VERSION - VARIABLE NAMING CHEAT SHEET
#  CEU Causality Economics Course
#
#  This file documents the naming conventions used in titanic_answers.R
#  Style: camelCase, short, intuitive
#
###############################################################################
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
#   fareByClass (not fare_by_class)
#   isFirstClass (not is_first_class)
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

# --- VECTORS ---
# myVec        generic numeric vector
# myNums       sequence of numbers
# naVec        vector containing NAs
# testVec      test data vector
# ages         vector of ages
# pclasses     vector of passenger classes
# dateStrs     vector of date strings
# dates1, dates2  Date objects

# --- TYPE CONVERSIONS ---
# charNum      character that looks like number ("123")
# numVal       result of as.numeric()
# numToChar    result of as.character()
# classFactor  factor version of class
# scoreFactor  factor version of scores
# scoreChar    character from factor

# --- LOGICAL CONDITIONS ---
# checkVals    values to check membership
# mySet        set to check against
# targets      target values for filtering
# matched      result of %in% matching
# result       general result variable


###############################################################################
# TITANIC-SPECIFIC VARIABLES (Sections 7+)
###############################################################################

# --- DATASET REFERENCES ---
# titanic_train   original dataset (from titanic package, keep as-is)
# dfCsv           data frame from CSV
# dfCsvTidy       data frame from read_csv (tidyverse)
# dfTsv           data frame from TSV
# dfXl            data frame from Excel
# dfSav           data frame from SPSS
# dfDta           data frame from Stata
# dfSubset        subset of columns
# dfSubset2       alternative subset
# newDf           newly created data frame

# --- COUNTS & SUMMARIES ---
# nPass           number of passengers
# nSurvived       number who survived
# survRate        survival rate (proportion)
# naMissing       count of missing values
# nRows           number of rows in data frame
# nSims           number of simulations
# sampleSize      size of each sample

# --- SUBSETS BY CLASS ---
# class1          first class passengers
# class2          second class passengers
# class3          third class passengers
# firstClass      (alternative) first class subset
# combinedBase    rbind result
# combinedTidy    bind_rows result

# --- SUBSETS BY SURVIVAL ---
# survivors       passengers who survived
# nonSurvivors    passengers who died

# --- SUBSETS BY CRITERIA ---
# fromCQ          passengers from Cherbourg or Queenstown

# --- LOGICAL CONDITIONS ---
# isFirstClass    TRUE for first class passengers
# dirExists       TRUE if directory exists

# --- AGGREGATIONS ---
# fareByClass     mean fare by class (aggregate result)
# aggMulti        multiple aggregations result
# classTable      frequency table of classes
# crossTab        cross-tabulation (class x survived)
# classProps      proportions of classes

# --- COLUMN ADDITIONS ---
# FamilySize      SibSp + Parch + 1 (added to dataset)
# AgeGroup        "Child" or "Adult" (added to dataset)
# FareLevel       "High" or "Low" (added to dataset)
# TicketClass     "First", "Second", "Third" (added to dataset)
# fareHigh        TRUE if Fare > 50 (in transmuted df)
# passId          PassengerId (in transmuted df)
# survived        Survived column (in transmuted df)

# --- SAMPLING ---
# idx             sampled row indices
# sample50        50 sampled passengers
# sample100       100 sampled passengers

# --- DATES ---
# departure       Titanic departure date
# sinking         Titanic sinking date
# rescue          Carpathia rescue date
# daysBefore      date one week before
# myDate          generic date for examples

# --- PORTS ---
# targetPorts     ports to filter by ("C", "Q")


###############################################################################
# ANALYSIS VARIABLES (Section 14)
###############################################################################

# --- CORRELATION ---
# corVal          single correlation value
# corMat          correlation matrix
# numCols         numeric columns for correlation

# --- T-TEST ---
# tResult         t.test() result object

# --- REGRESSION ---
# mod1            first regression model (lm object)
# mod2            second regression model (lm object)


###############################################################################
# CUSTOM FUNCTION VARIABLES (Section 15)
###############################################################################

# --- FUNCTION NAMES ---
# myMean          custom mean function
# myVar           custom variance function
# mySd            custom standard deviation function
# myRnorm         custom normal distribution sampler
# doubleIt        doubles input
# addTwo          adds two numbers
# samplePassengers  samples rows from data frame

# --- INSIDE FUNCTIONS ---
# x               input vector (function parameter)
# df              input data frame (function parameter)
# total           sum of values
# n               count of values
# result          computed result
# m               mean value
# devs            deviations from mean
# sqDevs          squared deviations
# v               variance
# samples         container for generated samples
# uniforms        uniform random numbers
# sumVal          sum of uniforms
# zScore          standardized value
# replace         sampling with replacement flag

# --- SIMULATION ---
# mySamples       samples from myRnorm
# sampleMeans     means from repeated sampling
# samp            single sample in loop


###############################################################################
# PREFIX CONVENTIONS
###############################################################################

# is...           logical condition (isFirstClass, isChild)
# n...            count (nPass, nSurvived, nSims, nRows)
# df...           data frame (dfCsv, dfSubset)
# my...           custom/user-created (myMean, myVar, myVec)
# ...Val          single value (corVal, numVal)
# ...Mat          matrix (corMat)
# ...Result       result object (tResult)
# ...Table        frequency table (classTable)
# ...Props        proportions (classProps)
# ...Strs         string vector (dateStrs)
# mod...          model object (mod1, mod2)
# sample...       sampled data (sample50, sampleMeans)
# ...By...        grouped result (fareByClass)


###############################################################################
# SUFFIX CONVENTIONS
###############################################################################

# ...Clean        after removing NAs (agesClean)
# ...Base         base R result (combinedBase)
# ...Tidy         tidyverse result (dfCsvTidy, combinedTidy)
# ...Factor       factor version (classFactor, scoreFactor)
# ...Char         character version (scoreChar, numToChar)
# ...Good/Bad     good vs bad example (meanGood, meanBad)


###############################################################################
# QUICK REFERENCE TABLE
###############################################################################
#
# Pattern              Example              Meaning
# ------------------   ------------------   -----------------------------------
# single lowercase     a, b, i, n, x        temporary/loop/simple variables
# camelCase            myNum, fareByClass   most variables
# is + Condition       isFirstClass         logical flag
# n + Thing            nPass, nSims         count of something
# df + Source          dfCsv, dfXl          data frame from source
# my + Function        myMean, myVar        custom function
# mod + Number         mod1, mod2           regression model
# sample + Size        sample50             sampled data
# ...Result            tResult              statistical test result
# ...Table             classTable           frequency table
# ...Mat               corMat               matrix
# ...Props             classProps           proportions
#
###############################################################################


###############################################################################
###############################################################################
#
#  END OF CHEAT SHEET
#
###############################################################################
###############################################################################

