# Number of samples
n <- 100
sample_set <- c(1,2,3)

sample_set_v2 <- c(TRUE, FALSE)

sampledList <- sample(sample_set_v2, n, replace = TRUE)

sampledList[]



# How many of the sampledList is TRUE?


# You can access the lenght of a vector via the function length()
length(sampledList)

# DO a for loop
count <- 0
for(i in 1:length(sampledList)) {
  # print(i)
  value <- sampledList[i]
  cat("for index ", i, "the value is:", value, "\n")
  
  # conditional on the value being true we need to increment count
  if(sampledList[i]) {
    
    count <- count + 1 
    cat(" TRUE is found!\n Count is incremented by 1:", count, "\n\n")
    
  }
  
}

count


# Can we do it with replace function?
# replace(x, list, values)
# x gets the sampledList, 

indexList <- which(sampledList)
sampledList_withApples <- replace(sampledList, indexList, "apples")
indexList

indexList_2 <- which(sampledList_withApples == "apples")
indexList_2

length(indexList)


# How many of the sampledList is TRUE?

as.numeric(TRUE)
as.numeric(FALSE)

someList <- c(1,2,3)
sum(someList)

sum(sampledList)



# Lets have a harder example


fList <- c('apple', 'orange', 'grape')

# recall that n was already defined as 100
sampledFList_balanced <- sample(fList, n, replace = TRUE)
sampledFList_unbalanced <- sample(fList, n, replace = TRUE, prob = c(0.5, 0.25, 0.25))



someList <- sampledFList_balanced == "orange"
sum(someList)
sum(sampledFList_balanced == "orange")
sum(sampledFList_balanced == "apple")
sum(sampledFList_balanced == "grape")

for(i in fList) {
  mySum <- sum(sampledFList_balanced == i)
  cat("Number of ", i, "is:", mySum, "\n\n")
}



# Table
table(sampledFList_balanced)
table(sampledFList_unbalanced)


# ---------



