MyData <- as.matrix(read.csv("../data/PoundHillData.csv",header = FALSE))
class(MyData)
head(MyData)

set.seed(1234567)
rnorm(1)

rnorm(10)
set.seed(1234567)
rnorm(11)

MyData <- read.csv("../data/trees.csv")
ls(pattern = "My*")

class(MyData)

file.exists("../data/trees.csv")

head(MyData)

MyData <- read.csv("../data/trees.csv", skip = 5) # skip first 5 lines

write.csv(MyData, "../results/MyData.csv")
dir("../results/") # Check if it worked
write.table(MyData[1,], file = "../results/MyData.csv",append=TRUE) # append
write.csv(MyData, "../results/MyData.csv", row.names=TRUE) # write row names
write.table(MyData, "../results/MyData.csv", col.names=FALSE)

source("basic_io.R")

a <- TRUE
if (a == TRUE) {
    print ("a is TRUE")
} else {
    print ("a is FALSE")
}

z <- runif(1) ## Generate a uniformly distributed random number
if (z <= 0.5) {print ("Less than a half")}

# FOR LOOPS
for (i in 1:10) {
    j <- i * i
    print(paste(i, " squared is", j ))
}

1:10

for(species in c('Heliodoxa rubinoides', 
                 'Boissonneaua jardini', 
                 'Sula nebouxii')) {
      print(paste('The species is', species))
}

v1 <- c("a","bc","def")
for (i in v1) {
    print(i)
}

# WHILE LOOPS
i <- 0
while (i < 10) {
    i <- i+1
    print(i^2)
}

i <- 0 #Initialize i
    while (i < Inf) {
        if (i == 10) {
            break 
        } else { # Break out of the while loop!  
            cat("i equals " , i , " \n")
            i <- i + 1 # Update i
    }
}

# USING NEXT
for (i in 1:10) {
  if ((i %% 2) == 0) # check if the number is odd
    next # pass to next iteration of loop 
  print(i)
}