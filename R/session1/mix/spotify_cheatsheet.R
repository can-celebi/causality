###############################################################################
###############################################################################
#
#  SPOTIFY - VARIABLE NAMING CHEAT SHEET
#  CEU Causality Economics Course
#
#  This file documents the naming conventions used in mix_answers.R
#  for Sections 7-11 (Spotify tracks dataset)
#  Style: camelCase, short, intuitive
#
###############################################################################
###############################################################################


###############################################################################
# DATASET OVERVIEW: moderndive::spotify_by_genre
###############################################################################
#
# Source: moderndive package
# Rows: 6,000 tracks from Spotify
# Columns: 21 variables
#
# ORIGINAL COLUMN NAMES:
#   track_id, artists, album_name, track_name, popularity, duration_ms,
#   explicit, danceability, energy, key, loudness, mode, speechiness,
#   acousticness, instrumentalness, liveness, valence, tempo,
#   time_signature, track_genre, popular_or_not
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
#   durMin      (not dur_min, not dur.min)
#   nrgLevel    (not nrg_level)
#   popByGenre  (not pop_by_genre)
#
###############################################################################


###############################################################################
# DATASET COLUMN ABBREVIATIONS
###############################################################################
#
# Full Name         Short Name    Type    Description
# ---------------   ----------    ----    ------------------------------------
# (dataset)         spot          tibble  Reference to spotify_by_genre
# track_id          track_id      chr     Spotify track ID (keep as-is)
# artists           artists       chr     Artist name(s) (keep as-is)
# album_name        album_name    chr     Album name (keep as-is)
# track_name        track_name    chr     Track/song name (keep as-is)
# popularity        pop           dbl     Popularity score (0-100)
# duration_ms       dur           dbl     Duration in milliseconds
# explicit          explicit      lgl     Contains explicit content?
# danceability      dance         dbl     Danceability score (0-1)
# energy            nrg           dbl     Energy score (0-1)
# key               key           dbl     Musical key (0-11) (keep as-is)
# loudness          loud          dbl     Loudness in decibels (dB)
# mode              mode          dbl     Mode (0=minor, 1=major) (keep as-is)
# speechiness       speech        dbl     Speechiness score (0-1)
# acousticness      acoust        dbl     Acousticness score (0-1)
# instrumentalness  instr         dbl     Instrumentalness score (0-1)
# liveness          live          dbl     Liveness score (0-1)
# valence           val           dbl     Valence/positiveness (0-1)
# tempo             tempo         dbl     Tempo in BPM (keep as-is)
# time_signature    time_signature dbl    Time signature (keep as-is)
# track_genre       genre         chr     Genre category
# popular_or_not    popCat        chr     "popular" or "not popular"
#
###############################################################################


###############################################################################
# SECTION 7: EXPLORING DATA
###############################################################################

# --- DATASET REFERENCES ---
# spot          short reference to spotify_by_genre

# --- COUNTS & SUMMARIES ---
# nTracks       total number of tracks (nrow)
# naMissing     count of missing values
# maxPop        index of most popular track (which.max)


###############################################################################
# SECTION 9: IMPORT/EXPORT
###############################################################################

# --- DATA FRAMES FROM DIFFERENT SOURCES ---
# dfCsv         data frame from CSV (base R read.csv)
# dfCsvTidy     data frame from CSV (tidyverse read_csv)
# dfTsv         data frame from TSV (read.table)
# dfXl          data frame from Excel (read_excel)
# dfSav         data frame from SPSS (read_sav)
# dfDta         data frame from Stata (read_dta)


###############################################################################
# SECTION 10: BASE R DATA MANIPULATION
###############################################################################

# --- COLUMN SELECTION ---
# cols          vector of column names to select
# dfSubset      subset of columns from dataset

# --- ROW FILTERING ---
# isRock        logical: TRUE if track is rock genre
# rockTracks    subset of rock genre tracks

# --- ADDED COLUMNS ---
# durMin        duration in minutes (duration_ms / 60000)
# nrgLevel      energy level ("High" or "Low")

# --- TRANSMUTED DATA ---
# newDf         newly created data frame
# track         track name (in newDf)
# popPct        popularity as percentage (in newDf)
# mood          "Happy" or "Sad" based on valence (in newDf)

# --- AGGREGATIONS ---
# popByGenre    mean popularity by genre (aggregate result)
# genreTable    frequency table of genres
# genreProps    proportions of genres


###############################################################################
# SECTION 11: TIDYVERSE DATA MANIPULATION
###############################################################################

# Same concepts as Section 10, but using tidyverse functions:
# select(), filter(), mutate(), transmute(), group_by(), summarise()

# --- AGGREGATION OUTPUTS ---
# n             count within group (from n() function)
# avgPop        average popularity (in summarise)
# avgNrg        average energy (in summarise)


###############################################################################
# SECTION 11F: FOR-LOOP VS TIDYVERSE
###############################################################################

# --- FOR-LOOP VERSION ---
# genres        unique genres (from unique())
# g             current genre in loop
# genreData     filtered data for current genre
# avgNrg        mean energy for current genre

# --- TIDYVERSE VERSION ---
# nrgByGenre    energy by genre (group_by + summarise result)


###############################################################################
# PREFIX CONVENTIONS
###############################################################################

# is...         logical condition (isRock, isExplicit)
# n...          count (nTracks, naMissing)
# df...         data frame (dfCsv, dfTsv, dfSubset)
# avg...        average/mean (avgPop, avgNrg)
# max...        maximum index or value (maxPop)
# ...ByGenre    grouped by genre (popByGenre, nrgByGenre)


###############################################################################
# SUFFIX CONVENTIONS
###############################################################################

# ...Tidy       tidyverse result (dfCsvTidy)
# ...Table      frequency table (genreTable)
# ...Props      proportions (genreProps)
# ...Min        in minutes (durMin)
# ...Level      categorical level (nrgLevel)
# ...Pct        percentage (popPct)
# ...Cat        category (popCat)


###############################################################################
# QUICK REFERENCE TABLE
###############################################################################
#
# Pattern              Example              Meaning
# ------------------   ------------------   -----------------------------------
# single lowercase     a, b, i, g           temporary/loop/simple variables
# camelCase            durMin, popByGenre   most variables
# is + Condition       isRock               logical flag
# n + Thing            nTracks              count of something
# df + Source          dfCsv, dfXl          data frame from source
# avg + Metric         avgPop, avgNrg       average of metric
# ...ByGenre           popByGenre           grouped by genre
# ...Table             genreTable           frequency table
# ...Props             genreProps           proportions
# ...Level             nrgLevel             categorical level
#
###############################################################################


###############################################################################
###############################################################################
#
#  END OF SPOTIFY CHEAT SHEET
#
###############################################################################
###############################################################################
