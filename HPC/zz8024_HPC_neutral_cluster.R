# clear off the work space and turn off the graphic
rm(list = ls())
graphics.off()

source("MAIN.R")

iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

# set the random seed
set.seed(iter)

# allocate the community scale
if (iter >= 1 && iter <= 25) {
  size <- 500
} else if (iter >= 26 && iter <= 50) {
  size <- 1000
} else if (iter >= 51 && iter <= 75) {
  size <- 2500
} else if (iter >= 76 && iter <= 100) {
  size <- 5000
} else {
  stop("the iter value is invalid, it should between 1 and 100")
}

# set the other parameter
 speciation_rate <- 0.1 
 interval_rich <- 1
 interval_oct <- size/10
 burn_in_generations <- 8*size
 wall_time <- 11.5
 
neutral_cluster_run(
   speciation_rate = speciation_rate,
   size = size,
   wall_time = wall_time,
   interval_rich = interval_rich,
   interval_oct = interval_oct,
   burn_in_generations = burn_in_generations
 )
 

 output_file_name <- paste("neutral_simulation_result_iter", iter, "_size", size, ".rda", sep = "")

 
