
# We have another script that generates the dataframes
# This script is in the same directory as this one
# hence we can simply use the name of this script as below to run it
# the script generates multiple data.frames, namely x, y and z.
source("01_data_generation.R")

# let's consider data.frame x
x
head(x)
names(x)
# colnames(x)

head(x$health_score)
summary(x$health_score)

# how big is this dataset
nrow(x)
length(x$health_score)

# let's change the name of health_score to health
names(x)[6] <- "health"
x$health

# let change the health_score so that the maximum is 100
summary(x$health)
myMax <- max(x$health)
myMax

# normalize
x$health_v2 <- x$health / myMax
# multiply by 100 (so that the max becomes 100)
x$health_v2 <- x$health_v2 * 100

# Summary helps is robust to NA cases
summary(x$health_v2)

mean(x$health_v2)


summary(x$income_numeric)

#  let's creat a new variable for high income individuals
x$highIncome <- ifelse(x$income_numeric >= 68058, 1, 0)



# average health of high income individuals
mean(x$health[x$highIncome == 1])
mean(x$health[x$highIncome == 0])

# subset of the dataset (data.frame) where we only have high income people
x_2 <- x[x$highIncome == 1,]

nrow(x)
nrow(x_2)


# side note about NA
var <- c(1,NA,3)
var
# if I want to take the average of some set of numbers
# and I don't know one the numbers in the set
# then I don't know the average of these numbers
mean(var)

# exclude NA cases
mean(var, na.rm = TRUE)
summary(var)


is.na(var)
!is.na(var)
# Variable without NA cases
var_2 <- var[!is.na(var)]
var_2
mean(var_2)



