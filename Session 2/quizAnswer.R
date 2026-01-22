# Quiz

# QUestion 1
myList <- c("apple", "something", "grape")
myList[3]
myList[myList == "grape"]
myList[-1] # this wont work

# Question 2
myList <- c(10, 20, 30, 40)
myList2 <- ifelse(myList > 25, 1, 0)
myList2


# Question 3
myList <- c(TRUE, FALSE, FALSE, TRUE)
sum(c(1,2,3,4))
sum(c(1,0,0,1))
sum(myList)

# Question 4

# part 1
myDataFrame <- data.frame(
  C1 = c(1,2,3,4),
  C2 = c(3,4,-5,-6),
  C3 = c(T,F,T,F)
  
)

names(myDataFrame)

nrow(myDataFrame)

# myList
# length(myList)
# dim(myDataFrame)
length(myDataFrame$C2)

# second row of column c3

myDataFrame$C3[2]
myDataFrame[2,3]
myDataFrame[2,"C3"]
myDataFrame$"C3"[2]

#  third part
myDataFrame2 <- myDataFrame[myDataFrame$C2 > 0,]








