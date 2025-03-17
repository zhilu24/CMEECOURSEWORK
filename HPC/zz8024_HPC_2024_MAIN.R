# CMEE 2024 HPC exercises R code main pro forma
# You don't HAVE to use this but it will be very helpful.
# If you opt to write everything yourself from scratch please ensure you use
# EXACTLY the same function and parameter names and beware that you may lose
# marks if it doesn't work properly because of not using the pro-forma.

name <- "Zhilu Zhang"
preferred_name <- "Lucia"
email <- "zhilu.zhang24@imperial.ac.uk"
username <- "zz8024"

# Please remember *not* to clear the work space here, or anywhere in this file.
# If you do, it'll wipe out your username information that you entered just
# above, and when you use this file as a 'toolbox' as intended it'll also wipe
# away everything you're doing outside of the toolbox.  For example, it would
# wipe away any automarking code that may be running and that would be annoying!

# Section One: Stochastic demographic population model

# Question 0

state_initialise_adult <- function(num_stages,initial_size){
  state <- c(rep(0, num_stages -1), initial_size) # All individuals are adults; last element is initial_size, others are 0
  return(state)  
}

state_initialise_spread <- function(num_stages,initial_size){
  population <- floor(initial_size / num_stages)
  remainder <- initial_size %% num_stages
  state <- rep(population, num_stages)
  if (remainder > 0) {
    state[1:remainder] <- state[1:remainder] + 1  
  }
  return(state)
}
source("Demographic.R")

# Question 1
question_1 <- function(){
  # construct growth matrix
  growth_matrix <- matrix(c(0.1, 0.0, 0.0, 0.0,
                            0.5, 0.4, 0.0, 0.0,
                            0.0, 0.4, 0.7, 0.0,
                            0.0, 0.0, 0.25, 0.4),
                          nrow=4, ncol=4, byrow=T)
  # construct reproduction matrix
  reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
                                  0.0, 0.0, 0.0, 0.0,
                                  0.0, 0.0, 0.0, 0.0,
                                  0.0, 0.0, 0.0, 0.0),
                                                        nrow=4, ncol=4, byrow=T)
  # obtain projection matrix
  projection_matrix <- reproduction_matrix + growth_matrix
  # define initial state
  initial_state_adult <- state_initialise_adult(4, 100)
  initial_state_spread <- state_initialise_spread(4, 100)
  # define simulated time
  simulation_length <- 24
  # run deterministic simulation
  result1 <- deterministic_simulation(initial_state_adult, projection_matrix, simulation_length)
  result2 <- deterministic_simulation(initial_state_spread, projection_matrix, simulation_length)
  
  png(filename="question_1.png", width = 600, height = 400)
  # plot your graph here
  plot(0:simulation_length, result1, type = "l", col = "blue", lwd = 2, xlab = "Time Steps", ylab = "Population Size", main = "Population Growth Over Time")
  lines(0:simulation_length, result2, type = "l", col = "red", lwd = 2)
  legend("topright", legend = c("All Adults Initially", "Even Distribution Across Four Stages"), col = c("blue", "red"), lty = 1, lwd = 2)
  dev.off()
  Sys.sleep(0.1)
  
  return("A population of all adults initially expands rapidly due to immediate reproduction, while an evenly distributed population grows steadily as younger individuals mature. Over time, growth patterns may converge, but a higher initial number of reproductive individuals leads to a larger overall population.")
}
question_1()


# Question 21
sum_vect <- function(x, y) {
  # the length for two vectors
  len_x <- length(x)
  len_y <- length(y)
  
  # pad the vector with zeros if its length is shorter
  if (len_x < len_y) {
    # zero-pad the vector to the correct length
    x <- c(x, rep(0, len_y - len_x))
  } else if (len_y < len_x) {
    y <- c(y, rep(0, len_x - len_y))
  }
  
  return(x + y)
}

# Question 2
question_2 <- function(){
  # define the clutch distribution
  clutch_distribution <- c(0.06,0.08,0.13,0.15,0.16,0.18,0.15,0.06,0.03)
  # same as the question1
  # construct growth matrix
  growth_matrix <- matrix(c(0.1, 0.0, 0.0, 0.0,
                            0.5, 0.4, 0.0, 0.0,
                            0.0, 0.4, 0.7, 0.0,
                            0.0, 0.0, 0.25, 0.4),
                          nrow=4, ncol=4, byrow=T)
  # construct reproduction matrix
  reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
                                  0.0, 0.0, 0.0, 0.0,
                                  0.0, 0.0, 0.0, 0.0,
                                  0.0, 0.0, 0.0, 0.0),
                                nrow=4, ncol=4, byrow=T)
  # define initial state
  initial_state_adult <- state_initialise_adult(4, 100)
  initial_state_spread <- state_initialise_spread(4, 100)
  # define simulated time
  simulation_length <- 24
  # run stochastic simulation
  sim1 <- stochastic_simulation(initial_state_adult, growth_matrix, reproduction_matrix, clutch_distribution, simulation_length)
  sim2 <- stochastic_simulation(initial_state_spread, growth_matrix, reproduction_matrix, clutch_distribution, simulation_length)
  
  png(filename="question_2.png", width = 600, height = 400)
  # plot your graph here
  plot(0:simulation_length, sim1, type = "l", col = "blue", lwd = 2,
       xlab = "Time", ylab = "Population Size", main = "Stochastic Simulations of Population Size")
  lines(0:simulation_length, sim2, col = "red", lwd = 2)
  legend("topright", legend = c("All Adults Initially", "Even Distribution Across Four Stages"), col = c("blue", "red"), lty = 1, lwd = 2)
  Sys.sleep(0.1)
  dev.off()
  
  return("The deterministic model produces smooth population changes based on fixed survival and reproduction rates, while the stochastic model introduces randomness, leading to uncertainty. In this particular situation, stochastic fluctuations caused rapid extinction (likely due to high mortality rates combined with insufficient recruitment). Stochastic fluctuations make small populations more vulnerable to early extinction, while deterministic models smooth out variability by relying on average survival and reproduction rates.")
}
question_2()


# Questions 3 and 4 involve writing code elsewhere to run your simulations on the cluster


# Question 5
question_5 <- function(){
  # set the initial condition
  initial_state_1 <- state_initialise_adult(4, 100)
  initial_state_2 <- state_initialise_adult(4, 10)
  initial_state_3 <- state_initialise_spread(4, 100)
  initial_state_4 <- state_initialise_spread(4, 10)
  initial_conditions <- list(
  initial_state_1, initial_state_2, initial_state_3, initial_state_4
  )

  # labels that define initial conditions
  condition_labels <- c("Large Adults Population", 
                        "Small Adults Population", 
                        "Large Evenly Distributed Population", 
                        "Small Evenly Distributed Population")

  # Get the list of simulation result files
  file_names <- list.files(path = "output_files", pattern = "simulation_results[0-9]+\\.rda$", full.names = TRUE)
  if (length(file_names) == 0) {
    stop("Error: No simulation results found in 'output_files'.")
  }
  # Initialize a vector to store the number of extinctions for each condition
  extinction_counts <- numeric(length(initial_conditions))
  
  # Loop through each initial condition
  for (i in 1:length(initial_conditions)) {
    # Initialize a counter for extinctions
    extinctions <- 0
    
    # Loop through each simulation file and determine which initial condition this file corresponds to
    condition_files <- file_names[(seq_along(file_names) %% 4) == (i %% 4)]
    for (file in condition_files) {
      load(file)
      
      for (sim in results) {
        if (is.vector(sim)) {
          sim <- matrix(sim, ncol = 1)  # Convert to matrix if it's a vector
        }
        if (!is.matrix(sim)) {
          stop("Error: sim is not a valid matrix or data frame. Check your simulation output.")
        }
        # Check if the population went extinct (final population size is 0)
        if (all(sim[nrow(sim), ] == 0)) {
          extinctions <- extinctions + 1
        }
      }
    }
    
    # store the number of extinctions for the current initial condition
    extinction_counts[i] <- extinctions
  }
    # calculate the proportion of extinctions for each initial condition 
    num_simulations <- (length(file_names) / 4) * 150
    if (num_simulations == 0) {
      stop("error: no valid simulation found")
    }
    extinction_proportions <- extinction_counts / num_simulations
    
    # plot the bar graph
    png(filename="question_5.png", width = 600, height = 400)
    barplot(extinction_proportions, names.arg = condition_labels,
            col = "blue", main = "Proportion of Leading Extinctions in Stochastic Simulation",
            ylab = "Proportion of Populations Going Extinct", xlab = "Initial Conditions")

    Sys.sleep(0.1)
    dev.off()
  # find the most likely extinct population
    most_possible_extinct <- condition_labels[which.max(extinction_proportions)]
   
  return(most_possible_extinct)
}
question_5()


# Question 6
question_6 <- function(){
  # set the specific initial condition - 3 and 4
  initial_state_3 <- state_initialise_spread(4, 100)
  initial_state_4 <- state_initialise_spread(4, 10)
  condition_labels_1 <- c("Large Evenly Distributed Population", "Small Evenly Distributed Population")
  
  # obtain the simulation results
  file_names <- list.files(path = "output_files", pattern = "simulation_results[0-9]+\\.rda$", full.names = TRUE)
  for (file in file_names) {
    load(file)  
    
  # store deviations
  deviations <- list()
  # store simulation
  all_simulations <- list()
  
  # ensure that only go through initial conditions 3 and 4
  for (i in 1:2) {
    condition_index <- i + 2 
    
      # Determine which initial condition this file corresponds to
      iter <- as.numeric(gsub("\\D", "", basename(file)))  
      file_condition_index <- ((iter - 1) %% 4) + 1  
      
      # only keep initial conditions 3 and 4
      if (file_condition_index == condition_index) {
        all_simulations[[length(all_simulations) + 1]] <- results[[1]]
      }
    }

      population_matrix <- do.call(cbind, all_simulations)
      
      # calculate the time step
      stochastic_population_trend <- rowMeans(population_matrix, na.rm = TRUE)
      # calculate the deterministic one
      if (i == 1) {
        deterministic_population_trend <- deterministic_simulation(initial_state_3)
      } else {
        deterministic_population_trend <- deterministic_simulation(initial_state_4)
      }
      # store the results
      deviations[[condition_labels_1[i]]] <- deviation
  }
      
      # calculate the deviation
      deviation <- stochastic_population_trend / deterministic_population_trend
      
      # check if the deviations are 0
      if (length(deviations) == 0) {
        stop("Error: No valid deviation data to plot!")
      }
      
    # set y axis
      y_min <- min(unlist(deviations), na.rm = TRUE)
      y_max <- max(unlist(deviations), na.rm = TRUE)
      
  png(filename="question_6", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  matplot(
    x = 1:length(deviations[[1]]), 
    y = do.call(cbind, deviations), 
    type = "l", lty = 1, col = c("blue", "red"),
    main = "Deviation of Stochastic Model from Deterministic Model",
    xlab = "Time Steps", ylab = "Deviation (Stochastic / Deterministic)",
    ylim = c(y_min, y_max)  
  )
  legend("topright", legend = names(deviations), col = c("blue", "red"), lty = 1)
  return("type your written answer here")
}
question_6()



# Section Two: Individual-based ecological neutral theory simulation 

# Question 7
species_richness <- function(community){
  # extract all unique species identifiers from the vector
  unique_species <- unique(community)
  # count the number of unique species
  richness <- length(unique_species)
  return(richness)
}

# Question 8
init_community_max <- function(size){
  # generate a sequence from 1 to size, ensuring each individual has a unique species
  max_species = seq_len(size)
  return(max_species)
}

# Question 9
init_community_min <- function(size){
  # create a vector where all elements are 1, represent the single dominant species
  min_species = rep(1,size)
  return(min_species)
}

# Question 10
choose_two <- function(max_value){
  sample(1:max_value, size = 2, replace = FALSE)
}

#test max_value = 4
choose_two(4)

# Question 11
neutral_step <- function(community){
  
  # randomly choose two distinct indices from the community vector
  indices <- choose_two(length(community))
  dead <- indices[1]
  reproducer <- indices[2]
  
  # replace dead index with reproducer's species
  community[dead] <- community[reproducer]
  return(community)
}

# test part
neutral_step(c(1,2))


# Question 12
neutral_generation <- function(community){
  x <- length(community)
  
  # determine number of neutral steps to perform
  if (x %% 2 == 0) {
    n_steps <- x / 2
  } else {
    # random choose floor or ceiling
    n_steps <- sample(c(floor(x/2), ceiling(x/2)), 1)
  } 
  
  # execute neutral_step n_steps times
  for (i in 1:n_steps) {
    community <- neutral_step(community)
  }
  return(community)
}


# Question 13
neutral_time_series <- function(community,duration)  {
  time_series <- numeric(duration + 1)
  # initialize time series
  time_series[1] <- length(unique(community))
  
  # iteratively simulate each generation
  for (i in 1:duration) {
    community <- neutral_generation(community)
    time_series[i+1] <- length(unique(community))
  }
  return(time_series)
}

# Question 14
question_14 <- function() {
  size <- 100
  duration <- 200
 
  # generate initial community
  initial_community <- init_community_max(size)
  
  ts <- neutral_time_series(initial_community, duration)
  
  png(filename="question_14.png", width = 600, height = 400)
  # plot your graph here
  plot(0:duration, ts, type = "o", col = "red",
       panel.first = grid(),
       main = "Neutral Model Species Richness Dynamics",
       xlab= "Generation", ylab = "Species Richness")
  Sys.sleep(0.1)
  dev.off()
  
  return("The system will always converge to a state where only one species remains. This happens because in a neutral model with stochastic replacement and no speciation, genetic drift leads to the eventual fixation of a single species over time. ")
}


# Question 15
neutral_step_speciation <- function(community,speciation_rate)  {
  # check if speciation rate is within a valid range
  if (speciation_rate < 0 || speciation_rate > 1) {
    stop("speciation_rate must be between 0 and 1")
  }
  
  # randomly determine whether speciation occurs
  if (runif(1) < speciation_rate) {
    new_species <- max(community) + 1
   
    # randomly choose the death position
    dead_index <- sample(length(community), 1)
    # replace with a new species
    community[dead_index] <- new_species
  } else {
    community <- neutral_step(community)
  }
  return (community)
}

# Question 16
neutral_generation_speciation <- function(community,speciation_rate)  {
  x <- length(community)
  
  # determine number of neutral steps to perform
  if (x %% 2 == 0) {
    n_steps <- x / 2
  } else {
    # random choose floor or ceiling
    n_steps <- sample(c(floor(x/2), ceiling(x/2)), 1)
  } 
  
  # execute neutral_step with speciation n_steps times
  for (i in 1:n_steps) {
    community <- neutral_step_speciation(community, speciation_rate)
  }
  
  return(community)
}
  

# Question 17
neutral_time_series_speciation <- function(community,speciation_rate,duration)  {
  time_series <- numeric(duration + 1)
  # initialize time series
  time_series[1] <- length(unique(community))
  
  # iteratively simulate each generation
  for (i in 1:duration) {
    community <- neutral_generation_speciation(community, speciation_rate)
    time_series[i+1] <- length(unique(community))
  }
  return(time_series)
}


# Question 18
question_18 <- function()  {  
  # set parameters
  size <- 100
  duration <- 200
  speciation_rate <- 0.1

  # generate initial communities
  community_max <- init_community_max(size)
  community_min <- init_community_min(size)
  
  ts_max <- neutral_time_series_speciation(community_max, speciation_rate, duration)
  ts_min <- neutral_time_series_speciation(community_min, speciation_rate, duration)

png(filename="question_18.png", width = 600, height = 400)
# plot your graph here
plot(0:duration, ts_max, type = "o", col = "red", lwd = 2,
     panel.first = grid(),
     main = "Neutral Model Simulation With Speciation",
     xlab= "Generation", ylab = "Species Richness",
     ylim = c(0, max(c(ts_max, ts_min)) +5))
lines(0:duration, ts_min, col = "blue", lwd = 2)
legend("topright", 
       legend = c("Max Initial Diversity", "Min Initial Diversity"),
       col = c("red", "blue"), lwd = 2, bty = "n")

  Sys.sleep(0.1)
  dev.off()
  
  return("The plot shows that despite different initial species richness conditions, the species richness eventually converges to a similar steady state. This is because the neutral model assumes that all species have the same fitness, so diversity is primarily driven by stochastic drift and speciation")
}



# Question 19
species_abundance <- function(community)  {
  # count the number of individuals for each species 
  abundance_table <- table(community)
  abundance_1 <- sort(as.numeric(abundance_table), decreasing = TRUE)
  
  return(abundance_1)
}


# Question 20
octaves <- function(abundance_vector) {
  # handle empty input cases
  if (length(abundance_vector) == 0) {
    return(integer(0))  
  }
  # determine which octave each belongs to 
  octave_bins <- floor(log2(abundance_vector)) + 1
  # count the number of species in each octave
  octave_counts <- tabulate(octave_bins)
  
  return(octave_counts)
}

# Question 21
sum_vect <- function(x, y) {
  # the length for two vectors
  len_x <- length(x)
  len_y <- length(y)
  
  # pad the vector with zeros if its length is shorter
  if (len_x < len_y) {
    # zero-pad the vector to the correct length
    x <- c(x, rep(0, len_y - len_x))
  } else if (len_y < len_x) {
    y <- c(y, rep(0, len_x - len_y))
  }
  
  return(x + y)
}
  

# Question 22

# define the record octave classification vector function
continue_simulation_record <- function(community, total_generations, record_interval, speciation_rate){
  octaves_list <- list()
  for (generation in seq(1, total_generations, by = record_interval)) {
    for (step in 1:record_interval) {
      community <- neutral_generation_speciation(community, speciation_rate)
    }
    abundance <- species_abundance(community)
    octave_vector <- octaves(abundance)
    octaves_list[[length(octaves_list) + 1]] <- octave_vector
  }
  return(octaves_list)
}

# define the mean octave distribution
mean_octaves <- function(octaves_list){
  sum_vector <- c()
  
  for (oct in octaves_list) {
    sum_vector <-sum_vect(sum_vector, oct)
  }
  
  mean_vector <- sum_vector / length(octaves_list)
  return(mean_vector)
}

question_22 <- function(size, speciation_rate, duration, total_generations, record_interval) {
  # set the parameters
  size <- 100
  speciation_rate <- 0.1
  burn_in <- 200
  total_generations <- 2000
  record_interval <- 20
  
  # generate initial communities
  community_max <- init_community_max(size)
  community_min <- init_community_min(size)
  
  # burn_in simulations
  for (i in 1:burn_in) {
    community_max <- neutral_generation_speciation(community_max, speciation_rate)
    community_min <- neutral_generation_speciation(community_min, speciation_rate)
  }
  
 # octave classification vector of species abundance after the burning period
  octave_vector_max_burnin <- octaves(species_abundance(community_max))
  octave_vector_min_burnin <- octaves(species_abundance(community_min))
  
  print(list(octave_vector_max_burnin, octave_vector_min_burnin))

  # Continue the simulation from the end of the burning period and record the octave classification
  octaves_vector_max <- continue_simulation_record(community_max, total_generations, record_interval, speciation_rate)
  octaves_vector_min <- continue_simulation_record(community_min, total_generations, record_interval, speciation_rate)

  # calculate the mean octave distribution
  mean_octaves_max <- mean_octaves(octaves_vector_max)
  mean_octaves_min <- mean_octaves(octaves_vector_min)
  
  # plot your graph here
  png("question_22.png", width = 600, height = 400)
  par(mfrow = c(1, 2))
  
  barplot(mean_octaves_max, main = "Max Diversity Initial Condition",
          xlab = "Octave Class", ylab = "Mean Number of Species", col = "blue")
  
  barplot(mean_octaves_min, main = "Min Diversity Initial Condition",
          xlab = "Octave Class", ylab = "Mean Number of Species", col = "red")
  
  Sys.sleep(0.1)
  dev.off()
  
  return("The plots show that despite different initial conditions, the species abundance distribution converges to a similar pattern. This occurs because the neutral model assumes equal fitness among species, leading to a steady-state distribution shaped by stochastic drift and speciation.")
}
question_22()


# Question 23
neutral_cluster_run <- function(speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, output_file_name) {
  # initialize the community
  community <- rep(1, size)
  time_series <- numeric()
  abundance_list <- list()
  generation <- 0
  
  # start the time
  start_time <- Sys.time()
  
  # simulate the cycle
  while (as.numeric(difftime(Sys.time(), start_time, units = "mins")) < wall_time) {
    generation <- generation + 1
    community <- neutral_generation_speciation(community, speciation_rate)
  
  # species richness record during the burning period  
  if (generation <= burn_in_generations && generation %% interval_rich == 0) {
    time_series <- append(time_series, length(unique(community)))
  }
  
  # the octave distribution is recorded every interval_oct
  if (generation %% interval_oct == 0) {
    abundance <- species_abundance(community)
    octave_vector <- octaves(abundance)
    abundance_list[[length(abundance_list) + 1]] <- octave_vector
  }
}

  # calculate the total running time
  total_time <- as.numeric(difftime(Sys.time(), start_time, units = "mins"))
  final_community <- community
    
  # save simulation result
  save(list = c("time_series", "abundance_list", "community", "total_time",
                "speciation_rate", "size", "wall_time", "interval_rich", 
                "interval_oct", "burn_in_generations"), 
       file = output_file_name)
}


# Questions 24 and 25 involve writing code elsewhere to run your simulations on
# the cluster

# Question 26 
process_neutral_cluster_results <- function() {
  file_names <- list.files(path = "output_files", pattern = "", full.names = TRUE)
  # define the community size
  community_sizes <- c(500, 1000, 2500, 5000)
  # initialise the list
  processed_results <- vector("list", length(community_sizes))
  names(processed_results) <- as.character(community_sizes)
  # go through community sizes
  for (size_index in seq_along(community_sizes)) {
    size <- community_sizes[size_index]
    
    # used to store abundance octaves after all burn-ins
    sum_octaves <- NULL
    num_simulations <- 0
    
    # go through the file
    for (file in file_names) {
      load(file)  

      if (!exists("results") || !is.list(results)) {
        next
      }
      
      # extract abundance octaves after burn-in
      afteroctaves <- results$abundance_octaves[(results$burn_in_time + 1):length(results$abundance_octaves), ]
      
      # calculates the average of abundance octave over all time steps
      mean_octave <- colMeans(afteroctaves, na.rm = TRUE)
      
      # add up all simulation results
      if (is.null(sum_octaves)) {
        sum_octaves <- mean_octave
      } else {
        sum_octaves <- sum_octaves + mean_octave
      }
      
      num_simulations <- num_simulations + 1
    }
    
    # calculate the final mean
    if (num_simulations > 0) {
      processed_results[[size_index]] <- sum_octaves / num_simulations
    } else {
      processed_results[[size_index]] <- rep(NA, length(mean_octave))
      warning(paste("No valid simulations found for community size:", size))
    }
  }
  
  # save the processed data
  save(processed_results, file = "processed_neutral_results.rda")
  plot_neutral_cluster_results <- function() {
    
    # addrees the results after processes
    load("processed_neutral_results.rda")
    
    # ensure the data can be processed
    if (!exists("processed_results") || !is.list(processed_results)) {
      stop("Error: processed_results data not found.")
    }
    
    # define community size
    community_sizes <- names(processed_results)
    
    # define the image output
    png(filename = "plot_neutral_cluster_results.png", width = 1000, height = 800)
    par(mfrow = c(2, 2))  # 2x2 multi-panel layout
    
    # through all community sizes and draw a bar graph
    for (size in community_sizes) {
      octave_data <- processed_results[[size]]
      
      # plot
      barplot(
        octave_data,
        main = paste("Community Size:", size),
        xlab = "Abundance Octave",
        ylab = "Mean Abundance",
        col = "blue",
        border = "white"
      )
    }
    dev.off()
    
    return(processed_results)
  }
  
  return("Data processed and saved in processed_neutral_results.rda")
}
  combined_results <- list() #create your list output here to return
  # save results to an .rda file


plot_neutral_cluster_results <- function(){
  
  # load combined_results from your rda file
  
  png(filename="plot_neutral_cluster_results", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return(combined_results)
}


# Challenge questions - these are substantially harder and worth fewer marks.
# I suggest you only attempt these if you've done all the main questions. 

# Challenge question A
Challenge_A <- function(){
  
  png(filename="Challenge_A", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
}

# Challenge question B
Challenge_B <- function() {
  
  png(filename="Challenge_B", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
}

# Challenge question C
Challenge_B <- function() {
  
  png(filename="Challenge_C", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
}

# Challenge question D
Challenge_D <- function() {
  
  png(filename="Challenge_D", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
}

# Challenge question E
Challenge_E <- function() {
  
  png(filename="Challenge_E", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}
