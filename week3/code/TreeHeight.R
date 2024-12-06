# Method for calculating tree height

data <-read.csv("../data/trees.csv")
head(data)

TreeHeight <- function(Angle.degrees, Distance.m) {
    
    # Check for missing values
  if (is.na(Angle.degrees) || is.na(Distance.m)) {
    return(NA)
  }
    radians <- Angle.degrees * pi / 180
    height <- Distance.m * tan(radians)
    print(paste("Tree height is:", height))
  
    return (height)
}



# calculate tree heights and add it as a new column
data$Tree.Height.m <- mapply(TreeHeight, data$Angle.degrees, data$Distance.m) 
 
# save the result 
write.csv(data, "../results/TreeHts.csv", row.names = FALSE)