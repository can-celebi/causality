getwd()

setwd("~/Documents/Teaching/CEU/Session 3")

x <- read.csv("ck_minwage.csv")

head(x)

nrow(x)

dim(x)


# fte = number of full time employees
# in NJ a minimum wage policy is being employed hence NJ is treatment effect

names(x)

names(x)[3] <- "state"

names(x)[2] <- "time"

names(x)[4] <- "nWorker"

head(x)


# Let's create the state dummy variable: 1 = NJ (treatment), 0 = PA (control)
x$state01 <- ifelse(x$state == "NJ", 1, 0)

# let's create the interaction dummy between state and time by hand
x$interactionDummy <- x$time * x$state01

mean(x$nWorker[x$time == 0])
# 17.64

mean(x$nWorker[x$time == 1])
# 17.51

mean(x$nWorker[x$state01 == 0])
# 18.76

mean(x$nWorker[x$state01 == 1])
# 17.29

# let's do some regressions

# m1.1: nWorker on state only
m1.1 <- lm(nWorker ~ state01, data = x)
summary(m1.1)

# the state coefficient is just the difference in means
m1.1$coefficients["state01"]
mean(x$nWorker[x$state01 == 1]) - mean(x$nWorker[x$state01 == 0])

# m1.2: nWorker on time only
m1.2 <- lm(nWorker ~ time, data = x)
summary(m1.2)

# the time coefficient is just the difference in means
m1.2$coefficients["time"]
mean(x$nWorker[x$time == 1]) - mean(x$nWorker[x$time == 0])

# m2: nWorker on state + time (additive, no interaction)
m2 <- lm(nWorker ~ state01 + time, data = x)
summary(m2)

# note: m2 coefficients are partial effects (controlling for the other variable)
# so they don't correspond to simple differences in means anymore

# m3.1: the full DiD model
m3.1 <- lm(nWorker ~ state01 + time + interactionDummy, data = x)
summary(m3.1)

# let's see how the DiD coefficients map to the four group means
mean_control_pre  <- mean(x$nWorker[x$state01 == 0 & x$time == 0])
mean_control_post <- mean(x$nWorker[x$state01 == 0 & x$time == 1])
mean_treat_pre    <- mean(x$nWorker[x$state01 == 1 & x$time == 0])
mean_treat_post   <- mean(x$nWorker[x$state01 == 1 & x$time == 1])

# intercept = mean of control group pre-treatment
mean_control_pre
m3.1$coefficients["(Intercept)"]

# state coefficient = difference between treatment and control, pre-treatment
mean_treat_pre - mean_control_pre
m3.1$coefficients["state01"]

# time coefficient = change over time for the control group
mean_control_post - mean_control_pre
m3.1$coefficients["time"]

# interaction coefficient = the DiD estimate!
# (change over time for treatment) minus (change over time for control)
(mean_treat_post - mean_treat_pre) - (mean_control_post - mean_control_pre)
m3.1$coefficients["interactionDummy"]

# Side: other ways to write the model
m3.2 <- lm(nWorker ~ state01 + time + state01*time, data = x)
summary(m3.2)
m3.3 <- lm(nWorker ~ state01*time, data = x)
summary(m3.3)

# let's display all three main models side by side
library(texreg)
screenreg(list(m1.1, m2, m3.1), caption = "Minimum wage: DiD results",
          caption.above = TRUE)

### Section 1.8: Chain composition robustness check
# why might chain composition matter? if NJ has mostly Burger Kings and PA has
# mostly other chains, and these chains have different employment levels, then
# a simple NJ-vs-PA comparison partly reflects chain differences rather than
# the policy effect. Let's check whether the proportion of BK restaurants differs:

x.nj <- x[x$state01 == 1 & x$time == 0, ]  # NJ, pre-period (avoid double-counting)
x.pa <- x[x$state01 == 0 & x$time == 0, ]  # PA, pre-period

# counts
table(x.nj$bk)
table(x.pa$bk)

# proportions
table(x.nj$bk) / nrow(x.nj)
table(x.pa$bk) / nrow(x.pa)

# the proportions are very close (about 41% BK in NJ vs 45% BK in PA), so chain
# composition is unlikely to be driving our results. Still, let's check robustness
# by running the DiD within each chain type separately:

# Burger King only
x.burgerKing <- x[x$bk == 1,]
x.burgerKing$interactionDummy <- x.burgerKing$time * x.burgerKing$state01

m4.bk <- lm(nWorker ~ state01 + time + interactionDummy, data = x.burgerKing)
summary(m4.bk)

# Non-Burger King restaurants only
x.notBK <- x[x$bk == 0,]
x.notBK$interactionDummy <- x.notBK$time * x.notBK$state01

m4.notBK <- lm(nWorker ~ state01 + time + interactionDummy, data = x.notBK)
summary(m4.notBK)

# compare all three models side by side
screenreg(list(m3.1, m4.bk, m4.notBK),
          custom.model.names = c("All restaurants", "Burger King", "Non-BK"),
          caption = "DiD by chain type", caption.above = TRUE)

# parallel trends check for Card & Krueger
# we only have two time periods (pre and post) so we can't do a full pre-trend test
# but we can plot the group means to visually inspect
library(ggplot2)

ckMeans <- data.frame(
  period = c("Pre", "Pre", "Post", "Post"),
  group  = c("Control (PA)", "Treatment (NJ)", "Control (PA)", "Treatment (NJ)"),
  nWorker   = c(mean_control_pre, mean_treat_pre, mean_control_post, mean_treat_post)
)
ckMeans$period <- factor(ckMeans$period, levels = c("Pre", "Post"))

ggplot(ckMeans, aes(x = period, y = nWorker, col = group, group = group)) +
  geom_point() + geom_line() +
  labs(title = "Card & Krueger: Parallel Trends Check",
       x = "Period", y = "Mean Number of Workers", col = "Group") +
  theme_bw()


### ============================================================
### UNDERSTANDING PARALLEL TRENDS WITH SIMULATED DATA
### Knife Attacks in Vienna: Do Weapon Ban Zones Work?
### ============================================================

# knife crime in Austria has been rising sharply in recent years
# nationwide: 822 incidents in 2020, rising every year to 2,596 in 2024 (record)
# Vienna alone: over 1,000 knife attacks in 2024
# Favoriten (10th district) is a well-known hotspot
#
# in March 2024, Vienna introduced a "Waffenverbotszone" (weapon ban zone)
# around Reumannplatz and Keplerplatz in Favoriten
# this is a designated area where carrying knives, weapons, or dangerous objects
# is prohibited 24/7. Police can search clothing, bags, and cars on suspicion.
# fines range from €1,000 for a first offence to €4,600 for repeat offenders.
#
# we want to know: did the weapon ban zone in Favoriten reduce knife attacks?
#
# to use DiD, we need a control district that was on the SAME trajectory
# as Favoriten BEFORE the ban. We compare two potential controls:
#
#   - Meidling (12th district): neighboring district, similar demographics,
#     knife attacks rising at the SAME rate → GOOD control (parallel trends hold)
#
#   - Innere Stadt (1st district): tourist/business center, very different dynamics,
#     knife attacks rising SLOWER → BAD control (parallel trends violated)
#
# the numbers below are simulated but inspired by real trends in Vienna

library(ggplot2)
library(texreg)
set.seed(42)


### STEP 1: simulate yearly knife attack data for three districts

# we observe knife attacks from 2018 to 2026
# the weapon ban zone is introduced in Favoriten at the start of 2024
# the true effect: reduces knife attacks by 30 per year

years <- 2018:2026
nYears <- length(years)
trueEffect <- -30
nObs <- 50  # observations per district per year (for proper standard errors)

# Why 50 observations? If we had just one observation per district-year, we would
# have 4 data points and 4 parameters — zero degrees of freedom, and R gives NaN
# for all standard errors. With 50 observations per year, we have proper variation
# to compute standard errors.

# Favoriten: starts at 80 attacks in 2018, rising by 15 per year
# after the weapon ban zone in 2024, attacks drop by 30 relative to the trend
baseline.favoriten <- 80
trend.favoriten <- 15

x.favoriten <- data.frame(year = integer(), attacks = numeric(), district = character())
for (i in 1:nYears) {
  yearMean <- baseline.favoriten + trend.favoriten * (i - 1)
  if (years[i] >= 2024) {
    yearMean <- yearMean + trueEffect
  }
  obs <- yearMean + rnorm(nObs, mean = 0, sd = 8)
  x.favoriten <- rbind(x.favoriten, data.frame(
    year = years[i], attacks = obs, district = "Favoriten"
  ))
}

head(x.favoriten)
nrow(x.favoriten)  # should be 450 (9 years × 50 obs)

# Meidling: starts at 50 attacks, ALSO rising by 15 per year — same trend as Favoriten
# neighboring district with similar demographics and nightlife
# same rate of increase as Favoriten, just a lower starting point
# no weapon ban zone here, so no treatment effect
# because the trend is the same, this is a GOOD control for DiD
baseline.meidling <- 50
trend.meidling <- 15

x.meidling <- data.frame(year = integer(), attacks = numeric(), district = character())
for (i in 1:nYears) {
  yearMean <- baseline.meidling + trend.meidling * (i - 1)
  obs <- yearMean + rnorm(nObs, mean = 0, sd = 8)
  x.meidling <- rbind(x.meidling, data.frame(
    year = years[i], attacks = obs, district = "Meidling"
  ))
}

head(x.meidling)
nrow(x.meidling)  # should be 450

# Innere Stadt: starts at 20 attacks, rising by only 2 per year — much slower than Favoriten
# the 1st district is the tourist/business center with different dynamics
# knife crime is rising here too, but much more slowly
# because the trend is DIFFERENT from Favoriten, this is a BAD control for DiD
baseline.innerestadt <- 20
trend.innerestadt <- 2

x.innerestadt <- data.frame(year = integer(), attacks = numeric(), district = character())
for (i in 1:nYears) {
  yearMean <- baseline.innerestadt + trend.innerestadt * (i - 1)
  obs <- yearMean + rnorm(nObs, mean = 0, sd = 8)
  x.innerestadt <- rbind(x.innerestadt, data.frame(
    year = years[i], attacks = obs, district = "Innere Stadt"
  ))
}

head(x.innerestadt)
nrow(x.innerestadt)  # should be 450


### STEP 2: What parallel trends really means

# Parallel trends does NOT mean the two groups have the same level. It means they
# are CHANGING AT THE SAME RATE before the treatment. Favoriten can have more knife
# attacks than Meidling — that is fine. What matters is whether both are increasing
# by roughly the same amount each year.
#
# To check this, we need MULTIPLE PRE-TREATMENT PERIODS. A before-and-after plot
# with just two time points tells you nothing about whether trends were parallel.

# compute yearly means for each district
meanByYear <- function(df, yrs) {
  result <- c()
  for (y in yrs) {
    result <- c(result, mean(df$attacks[df$year == y]))
  }
  return(result)
}

x.means <- data.frame(
  year     = rep(years, 3),
  district = rep(c("Favoriten", "Meidling", "Innere Stadt"), each = nYears),
  attacks  = c(meanByYear(x.favoriten, years),
               meanByYear(x.meidling, years),
               meanByYear(x.innerestadt, years))
)

head(x.means)

# Visual check: Favoriten vs Meidling (good control)
x.goodTrends <- x.means[x.means$district != "Innere Stadt", ]

ggplot(x.goodTrends, aes(x = year, y = attacks, col = district)) +
  geom_point(size = 2) + geom_line(linewidth = 1) +
  geom_vline(xintercept = 2024, linetype = "dashed", col = "black") +
  annotate("text", x = 2024.2, y = max(x.goodTrends$attacks),
           label = "Weapon ban zone", hjust = 0) +
  labs(title = "Parallel Trends Check: Favoriten vs Meidling",
       subtitle = "Both rise at ~15/year before 2024 (parallel trends HOLD)",
       x = "Year", y = "Mean Knife Attacks per Year", col = "District") +
  theme_bw()

# Before 2024 the two lines rise at the same rate — the gap stays constant.
# After 2024, Favoriten drops sharply while Meidling keeps rising.
# The divergence is the treatment effect.

# Visual check: Favoriten vs Innere Stadt (bad control)
x.badTrends <- x.means[x.means$district != "Meidling", ]

ggplot(x.badTrends, aes(x = year, y = attacks, col = district)) +
  geom_point(size = 2) + geom_line(linewidth = 1) +
  geom_vline(xintercept = 2024, linetype = "dashed", col = "black") +
  annotate("text", x = 2024.2, y = max(x.badTrends$attacks),
           label = "Weapon ban zone", hjust = 0) +
  labs(title = "Parallel Trends Check: Favoriten vs Innere Stadt",
       subtitle = "Favoriten rises at ~15/year, Innere Stadt at ~2/year (parallel trends VIOLATED)",
       x = "Year", y = "Mean Knife Attacks per Year", col = "District") +
  theme_bw()

# Before 2024 the lines are clearly diverging — the gap grows every year.
# Parallel trends does NOT hold.


### Statistical test for parallel trends

# Visual inspection is the most common approach in applied research — many
# influential DiD papers rely primarily on visual evidence. But we can also
# supplement the visual check with a statistical test.
#
# The idea: if parallel trends hold, the GAP between the two districts should
# stay constant over time before the treatment. If one district is rising faster
# than the other, the gap is growing — that's a violation.
#
# We can test this by regressing the outcome on year, a district dummy, and their
# INTERACTION — using only pre-treatment data. Why does the interaction capture this?
#
# - The year coefficient captures the overall time trend
# - The district01 coefficient captures the level difference between districts
# - The year:district01 interaction captures whether the SLOPE OVER TIME is different
#
# If the interaction is significant, it means one district is changing faster than
# the other — the trends are not parallel. If it is NOT significant, we cannot
# reject that the trends are the same.
#
# Important caveat: failing to reject parallel trends does NOT prove they hold
# (Roth 2022, Kahn-Lang & Lang 2020). The test may simply lack statistical power.
# So a non-significant result is reassuring but not proof.

# combine Favoriten and Meidling, pre-treatment only
x.preTrends.good <- rbind(
  x.favoriten[x.favoriten$year < 2024, ],
  x.meidling[x.meidling$year < 2024, ]
)
x.preTrends.good$district01 <- ifelse(x.preTrends.good$district == "Favoriten", 1, 0)

# test: does the time trend differ between districts?
# if the interaction (district × year) is NOT significant, trends are parallel
trend.test.good <- lm(attacks ~ year + district01 + year:district01, data = x.preTrends.good)
summary(trend.test.good)

# The coefficient on year:district01 tests whether Favoriten's yearly trend is
# different from Meidling's. If it is NOT significant (p > 0.05), we cannot
# reject parallel trends — good news for our DiD.

# now the same test with Innere Stadt
x.preTrends.bad <- rbind(
  x.favoriten[x.favoriten$year < 2024, ],
  x.innerestadt[x.innerestadt$year < 2024, ]
)
x.preTrends.bad$district01 <- ifelse(x.preTrends.bad$district == "Favoriten", 1, 0)

trend.test.bad <- lm(attacks ~ year + district01 + year:district01, data = x.preTrends.bad)
summary(trend.test.bad)

# Here year:district01 SHOULD be significant — confirming that the pre-trends are
# different and Innere Stadt is a bad control.


### STEP 3: DiD with the GOOD control (Meidling)

# filter to years 2023 and 2024 only
fav.before <- mean(x.favoriten$attacks[x.favoriten$year == 2023])
fav.after  <- mean(x.favoriten$attacks[x.favoriten$year == 2024])

mei.before <- mean(x.meidling$attacks[x.meidling$year == 2023])
mei.after  <- mean(x.meidling$attacks[x.meidling$year == 2024])

# DiD by hand:
# (change in Favoriten) minus (change in Meidling)
did.good <- (fav.after - fav.before) - (mei.after - mei.before)
did.good
# should be close to -30 (the true effect of the weapon ban zone)

# let's also do it as a regression using the full panel data for 2023-2024
x.good <- rbind(
  x.favoriten[x.favoriten$year %in% c(2023, 2024), ],
  x.meidling[x.meidling$year %in% c(2023, 2024), ]
)
x.good$district01 <- ifelse(x.good$district == "Favoriten", 1, 0)
x.good$time <- ifelse(x.good$year == 2024, 1, 0)
x.good$interactionDummy <- x.good$district01 * x.good$time

head(x.good)
nrow(x.good)  # should be 200 (2 years × 2 districts × 50 obs)

m.good <- lm(attacks ~ district01 + time + interactionDummy, data = x.good)
summary(m.good)

m.good$coefficients["interactionDummy"]
# the interaction coefficient is close to -30 (the true effect), with proper
# standard errors and a significant p-value


### STEP 4: DiD with the BAD control (Innere Stadt)

inn.before <- mean(x.innerestadt$attacks[x.innerestadt$year == 2023])
inn.after  <- mean(x.innerestadt$attacks[x.innerestadt$year == 2024])

# DiD by hand with the bad control
did.bad <- (fav.after - fav.before) - (inn.after - inn.before)
did.bad
# this will NOT be close to -30

# regression using the full panel data
x.bad <- rbind(
  x.favoriten[x.favoriten$year %in% c(2023, 2024), ],
  x.innerestadt[x.innerestadt$year %in% c(2023, 2024), ]
)
x.bad$district01 <- ifelse(x.bad$district == "Favoriten", 1, 0)
x.bad$time <- ifelse(x.bad$year == 2024, 1, 0)
x.bad$interactionDummy <- x.bad$district01 * x.bad$time

head(x.bad)

m.bad <- lm(attacks ~ district01 + time + interactionDummy, data = x.bad)
summary(m.bad)

m.bad$coefficients["interactionDummy"]
# the estimate is much more negative than -30 — biased because the control group
# was barely rising


### STEP 5: compare the results

# true effect of the weapon ban zone
trueEffect

# DiD with Meidling (good control, parallel trends hold)
did.good
m.good$coefficients["interactionDummy"]

# DiD with Innere Stadt (bad control, parallel trends violated)
did.bad
m.bad$coefficients["interactionDummy"]

# Meidling gives us an estimate close to -30 (the true effect)
# Innere Stadt overestimates the effect because it was rising at only 2/year while
# Favoriten was rising at 15/year. DiD subtracts the control's change from the
# treated's change — if the control barely changes, the DiD picks up the treatment
# effect PLUS the pre-existing difference in trends.
# This is exactly what it means for parallel trends to be violated


### ============================================================
### PANEL DATA TWFE: Alcohol Taxes and Traffic Fatalities
### Stock and Watson (based on Ruhm 1996)
### ============================================================

# How is this different from Card & Krueger?
#
# In Card & Krueger, the setup was clean: NJ got a minimum wage increase, PA did not.
# One treated group, one control group, one before period, one after period. We built
# a state × time interaction and the coefficient on that was the DiD.
#
# The Fatalities data is completely different. There is NO SINGLE TREATMENT EVENT.
# Beer tax is not a binary on/off policy — it is a continuous dollar amount that every
# state has, and each state sets its own level. Some states raise their beer tax in
# 1983, others in 1986, some never change it at all. The amounts differ too: one state
# might go from $0.50 to $0.80, another from $0.30 to $0.35.
#
# So this is NOT a "some states got treated and others didn't" story. It is: "every
# state has a beer tax, and we want to know whether states with higher beer taxes have
# fewer traffic deaths." The challenge is that states differ in many ways (rural vs
# urban, road quality, culture), so we cannot just compare high-tax states to low-tax
# states — that would be confounded.
#
# WHY FIXED EFFECTS HELP:
#
# State fixed effects remove everything that is constant within a state over time.
# Montana will always be rural with long empty highways. New York will always be dense
# and urban. Alabama will always have a different drinking culture than Utah. These
# are things that don't change (or change very slowly) and that affect both the beer
# tax a state sets AND its fatality rate. Without state fixed effects, we are comparing
# Montana to New York and attributing the difference to beer taxes — that's confounded.
# With state fixed effects, we are comparing Montana to itself across years: "when
# Montana's beer tax went up, did Montana's fatalities go down?"
#
# Year fixed effects remove anything that affects all states equally in a given year.
# For example: federal seatbelt laws passed in 1984 reduced fatalities everywhere.
# The 1982 recession reduced driving nationwide. Improvements in car safety technology
# (airbags, crumple zones) happened over time for everyone. Without year fixed effects,
# if beer taxes happened to rise during a period when cars were also getting safer,
# we'd incorrectly attribute the decline in fatalities to taxes rather than technology.
#
# THE COST OF FIXED EFFECTS: DEGREES OF FREEDOM
#
# Every fixed effect we add uses up one degree of freedom. Think of it this way.
# We have 7 years of data for Montana. Without any fixed effects, all 7 observations
# help us figure out the relationship between beer tax and fatalities. But when we add
# a Montana fixed effect, we are telling the model: "estimate Montana's own average
# fatality rate." Computing that average uses up one of Montana's 7 observations' worth
# of information — now only 6 are left to tell us how Montana's fatalities move around
# that average when beer tax changes.
#
# We have 48 states, and we add a dummy for each one. R drops one state as the reference
# category, so we estimate 47 dummy coefficients — that's 47 state-specific averages
# the model has to learn from the data. Same logic for the 7 years: R drops one year
# as the reference, giving us 6 year dummy coefficients.
#
# So: 47 (state dummies) + 6 (year dummies) = 53 degrees of freedom consumed by the
# fixed effects, out of 336 total observations (48 × 7). After paying this cost, we
# have 336 − 54 = 282 degrees of freedom left for estimating the beer tax effect and
# other controls. That is still plenty.
#
# WHY THERE IS NO INTERACTION TERM:
#
# In the 2×2 case, we needed the state × time interaction because state is constant
# over time (NJ is always NJ) and time is the same for everyone (everyone has the
# same before and after). The interaction was the only variable that varied both
# across states AND within states over time.
#
# Here, beertax already varies both across states (California's tax ≠ Texas's tax)
# AND within states over time (California's tax in 1982 ≠ California's tax in 1988).
# So beertax naturally has the property that the interaction had in the 2×2 case.
# When we add state and year fixed effects, they strip away the between-state
# differences and the common time trends, leaving only: "in years when this specific
# state changed its beer tax differently from the national average, did its fatality
# rate change differently from the national average?"

library(AER)
data(Fatalities)

head(Fatalities)
dim(Fatalities)

# let's create the fatality rate per 10,000 people
Fatalities$fatal_rate <- Fatalities$fatal / Fatalities$pop * 10000

head(Fatalities$fatal_rate)


# simple plot of fatalities and beer taxes for 1982
library(ggplot2)

Fatalities.1982 <- Fatalities[Fatalities$year == "1982", ]

ggplot(Fatalities.1982, aes(x = beertax, y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Beer Tax vs Fatality Rate (1982)",
       x = "Beer Tax", y = "Fatality Rate (per 10,000)") +
  theme_bw()

# simple plot by state across all years
ggplot(Fatalities, aes(x = beertax, y = fatal_rate, col = state)) +
  geom_point(alpha = 0.4) + geom_smooth(method = "lm", se = FALSE) +
  guides(col = "none") +
  labs(title = "Beer Tax vs Fatality Rate by State",
       x = "Beer Tax", y = "Fatality Rate (per 10,000)") +
  theme_bw()


### let's explore the additional control variables before running regressions

### Exploring control variables before running regressions

# drinkage: minimum legal drinking age in the state
# states with lower drinking ages may have more young drivers drinking
summary(Fatalities$drinkage)

ggplot(Fatalities, aes(x = drinkage, y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Minimum Drinking Age vs Fatality Rate",
       x = "Minimum Legal Drinking Age", y = "Fatality Rate (per 10,000)") +
  theme_bw()

# jail: mandatory jail sentence for DUI? (yes/no)
# states with mandatory jail for DUI may deter drunk driving
summary(Fatalities$jail)

ggplot(Fatalities, aes(x = jail, y = fatal_rate)) +
  geom_boxplot() +
  labs(title = "Mandatory Jail for DUI vs Fatality Rate",
       x = "Mandatory Jail Sentence", y = "Fatality Rate (per 10,000)") +
  theme_bw()

# miles: average miles driven per driver in the state
# more driving = more exposure to risk = more fatalities
summary(Fatalities$miles)

ggplot(Fatalities, aes(x = miles, y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Miles Driven vs Fatality Rate",
       x = "Average Miles per Driver", y = "Fatality Rate (per 10,000)") +
  theme_bw()

# distribution of miles (raw vs log)
par(mfrow = c(1, 2))
hist(Fatalities$miles, breaks = 30, main = "Distribution of Miles", xlab = "Miles")
hist(log(Fatalities$miles), breaks = 30, main = "Distribution of log(Miles)", xlab = "log(Miles)")
par(mfrow = c(1, 1))

# log(miles) gives a better linear fit
ggplot(Fatalities, aes(x = log(miles), y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "log(Miles) vs Fatality Rate",
       x = "log(Average Miles per Driver)", y = "Fatality Rate (per 10,000)") +
  theme_bw()

# unemp: unemployment rate in the state
# higher unemployment = fewer people commuting = less driving = fewer fatalities
# also: economic hardship may affect drinking behavior
summary(Fatalities$unemp)

ggplot(Fatalities, aes(x = unemp, y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Unemployment Rate vs Fatality Rate",
       x = "Unemployment Rate", y = "Fatality Rate (per 10,000)") +
  theme_bw()

# income: per capita income in the state
# wealthier states may have better roads, safer cars, better hospitals
# but also more cars on the road
summary(Fatalities$income)

ggplot(Fatalities, aes(x = income, y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Income vs Fatality Rate",
       x = "Per Capita Income", y = "Fatality Rate (per 10,000)") +
  theme_bw()

# Why log(income)?
# Income is right-skewed: most states cluster at lower values with a long right tail
# Log transform makes the distribution more symmetric
# It also changes the interpretation: a 1% change in income is associated with
# a certain change in fatality rate (instead of a $1 change in income)
# This makes more sense because going from $10,000 to $11,000 is a big deal
# but going from $100,000 to $101,000 is not

# distribution of income (raw vs log)
par(mfrow = c(1, 2))
hist(Fatalities$income, breaks = 30, main = "Distribution of Income", xlab = "Income")
hist(log(Fatalities$income), breaks = 30, main = "Distribution of log(Income)", xlab = "log(Income)")
par(mfrow = c(1, 1))

# we can see log(income) gives a better linear fit
ggplot(Fatalities, aes(x = income, y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Income vs Fatality Rate (levels)",
       x = "Per Capita Income", y = "Fatality Rate (per 10,000)") +
  theme_bw()

ggplot(Fatalities, aes(x = log(income), y = fatal_rate)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  labs(title = "log(Income) vs Fatality Rate",
       x = "log(Per Capita Income)", y = "Fatality Rate (per 10,000)") +
  theme_bw()


### let's understand TWFE by building it up manually with lm()

# mod1: simple OLS, no fixed effects
mod1.manual <- lm(fatal_rate ~ beertax, data = Fatalities)
summary(mod1.manual)

# mod2: state fixed effects only
# factor(state) creates a dummy variable for each state
# R automatically picks one state as the reference category (drops it)
# so if we have 48 states, we get 47 dummy coefficients
length(unique(Fatalities$state))

mod2.manual <- lm(fatal_rate ~ beertax + factor(state), data = Fatalities)
summary(mod2.manual)

# notice the output is huge because we have a dummy for each state
# let's just look at the beertax coefficient
mod2.manual$coefficients["beertax"]

# mod3: state AND year fixed effects (this is two-way fixed effects / TWFE)
# factor(year) creates a dummy for each year
# so now we control for both state-level differences and year-level shocks
length(unique(Fatalities$year))

mod3.manual <- lm(fatal_rate ~ beertax + factor(state) + factor(year), data = Fatalities)
summary(mod3.manual)

mod3.manual$coefficients["beertax"]

# mod4: TWFE with additional controls
mod4.manual <- lm(fatal_rate ~ beertax + drinkage + jail + miles + unemp + log(income)
                  + factor(state) + factor(year), data = Fatalities)
summary(mod4.manual)

mod4.manual$coefficients["beertax"]


# now let's compare: the feols package does the exact same thing
# but much more efficiently and with cleaner output
# the "|" symbol separates the fixed effects from the other variables
# so feols absorbs the fixed effects instead of showing 50+ dummy coefficients

# install.packages("fixest")
library(fixest)

mod1 <- feols(fatal_rate ~ beertax, data = Fatalities)
mod2 <- feols(fatal_rate ~ beertax | state, data = Fatalities)
mod3 <- feols(fatal_rate ~ beertax | state + year, data = Fatalities)
mod4 <- feols(fatal_rate ~ beertax + drinkage + jail + miles + unemp + log(income)
              | state + year, data = Fatalities)

# let's verify the coefficients match our manual approach
mod1$coefficients["beertax"]
mod1.manual$coefficients["beertax"]

mod2$coefficients["beertax"]
mod2.manual$coefficients["beertax"]

mod3$coefficients["beertax"]
mod3.manual$coefficients["beertax"]

mod4$coefficients["beertax"]
mod4.manual$coefficients["beertax"]
# same! feols just does it more efficiently

# let's display all models side by side
library(texreg)
screenreg(list(mod1, mod2, mod3, mod4), caption = "TWFE: Beer Tax and Fatality Rate",
          caption.above = TRUE)

# Let's interpret this table:
#
# - Model 1 (no fixed effects): beer tax coefficient is POSITIVE (+0.36). This seems
#   to say higher taxes mean MORE deaths — clearly wrong as a causal claim. States
#   with high beer taxes also happen to have higher fatality rates for unrelated
#   reasons (rural roads, culture, etc.). This is omitted variable bias.
#
# - Model 2 (state fixed effects): the coefficient FLIPS TO NEGATIVE (-0.66). This
#   is the most important change. Now we compare each state to itself over time:
#   when a state raised its tax, did fatalities fall? Yes. State fixed effects
#   remove all time-invariant confounders. R-squared jumps dramatically because
#   most variation is between states.
#
# - Model 3 (state + year fixed effects = TWFE): the coefficient barely changes
#   (-0.64). Adding year fixed effects controls for nationwide trends (safer cars,
#   federal campaigns). The fact that the coefficient barely moved from Model 2 to
#   Model 3 tells us that common time trends were not seriously biasing Model 2.
#
# - Model 4 (TWFE + controls): the coefficient shrinks to -0.45. Some variation we
#   attributed to beer taxes is now explained by drinking age, jail policies, miles,
#   unemployment, and income. This is the most credible specification.
#
# Key takeaway: the sign flips from positive to negative once we add state fixed
# effects. Without them, you get the exact wrong answer. This is why fixed effects matter.

# install.packages("modelsummary")
library(modelsummary)

cm <- c('beertax' = 'Beer tax')
modelplot(list("(1) No FE" = mod1,
               "(2) State FE" = mod2,
               "(3) State + Year FE" = mod3,
               "(4) TWFE + Controls" = mod4),
          coef_map = cm) +
  geom_vline(xintercept = 0, linetype = "dashed", col = "gray50") +
  labs(title = "Beer Tax Coefficient Across Model Specifications",
       subtitle = "Dots = point estimates, lines = 95% confidence intervals",
       x = "Coefficient on Beer Tax",
       y = "Model") +
  theme_bw()

# The plot shows how the coefficient changes dramatically once we add fixed effects.
# Model 1 (no FE) is positive and wrong. Models 2-4 are all negative and credible.