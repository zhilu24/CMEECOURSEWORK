MyDF <- read.csv("../data/EcolArchives-E089-51-D1.csv")
dim(MyDF) #check the size of the data frame you loaded
str(MyDF)
head(MyDF)

require(tidyverse)
glimpse(MyDF)

plot(MyDF$Predator.mass,MyDF$Prey.mass)

plot(log(MyDF$Predator.mass),log(MyDF$Prey.mass))

plot(log10(MyDF$Predator.mass),log10(MyDF$Prey.mass))

hist(MyDF$Prey.mass)

hist(log10(MyDF$Prey.mass), xlab = "log10(Prey Mss(g))", ylab = "Count")

boxplot(log10(MyDF$Predator.mass), xlab = "Location", ylab = "log10(Predator Mass)", main = "Predator mass")