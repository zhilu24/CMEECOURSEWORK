rm(list=ls())
 
# read in data
load("../data/KeyWestAnnualMeanTemperature.RData")
ls()
 
# explore data
class(ats)
head(ats)
plot(ats)
 
# Calculate the correlation coefficient between year and temperature
cor_1 <- cor(ats$Year, ats$Temp)
print(cor_1)
 
# set permutation parameters
simulations <- 10000 
count <- 0
 
# set random seeds
set.seed(123)
# find correlation coefficients for shuffled data
for (i in 1:simulations) {
  Temp_1 <- sample(ats$Temp) # Randomly shuffle the temperatures
  cor_2 <- cor(ats$Year, Temp_1)
  if (cor_2 > cor_1) {
    count <- count + 1
  }
}
 
# Calculate the fraction of the random correlation coefficients greater than the observed one
fraction <- count / simulations
 
print(fraction)