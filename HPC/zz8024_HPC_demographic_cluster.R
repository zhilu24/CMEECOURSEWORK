# CMEE 2024 HPC exercises R code pro forma
# For stochastic demographic model cluster run

rm(list=ls()) # good practice 
graphics.off()
source("Demographic.R")
iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))
set.seed(iter)

# the sum vector
sum_vect<- function(x,y){
  len_x <- length(x)
  len_y <- length(y)
  if(len_x < len_y) {
    x <- c(x, rep(0, len_y - len_x))
  }
  else if(len_y < len_x){
    y <- c(y, rep(0, len_x - len_y))
  }
  
  return(x+y)
} 

# the initial condition
initial_conditions <- list(
  initial_state_1 <- state_initialise_adult(4, 100),
  initial_state_2 <- state_initialise_adult(4, 10),
  initial_state_3 <- state_initialise_spread(4, 100),
  initial_state_4 <- state_initialise_spread(4, 10)
)

# Selects the initial condition based on iter and initializes a list to store 150 simulation results.
condition_index <- initial_conditions[[((iter - 1) %% 4) + 1]]
results <- vector("list", 150)

# define conditions
growth_matrix <- matrix(c(0.1, 0.0, 0.0, 0.0,
                          0.5, 0.4, 0.0, 0.0,
                          0.0, 0.4, 0.7, 0.0,
                          0.0, 0.0, 0.25, 0.4),
                        nrow=4, ncol=4, byrow=T)
reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
                                0.0, 0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0, 0.0),
                              nrow=4, ncol=4, byrow=T)
clutch_distribution <- c(0.06,0.08,0.13,0.15,0.16,0.18,0.15,0.06,0.03)
for(i in 1:150) {
  results[[i]] <- stochastic_simulation(
    initial_state = condition_index,
    growth_matrix = growth_matrix,
    reproduction_matrix = reproduction_matrix,
    clutch_distribution = clutch_distribution,
    simulation_length = 120
  )
}

# generate output files
output_file <- paste0("simulation_results", iter, ".rda")
save(results, file = output_file)
