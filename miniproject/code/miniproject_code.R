# clear the workspace
rm(list=ls())

# load packages
library(dplyr)
library(ggplot2)
library(minpack.lm)
library(tidyr)

### data processing part

# read dataset
data = read.csv("../data/LogisticGrowthData.csv") 

# converts all negative values in the time column to 0 values
# transform the negative and 0 values for popbio to NA value
data <- data %>%
  mutate(
    Time = ifelse(Time <0, 0, Time),
    PopBio = ifelse(PopBio <= 0, NA, PopBio)
    )

# check for invalid value
sapply(data, function(x) sum(is.infinite(x)))
sapply(data, function(x) sum(is.na(x)))

# delete the NA value row
data <- na.omit(data)

# construct the log-transformed column for popbio value
data$log_PopBio <- log(data$PopBio)

# check for invalid value after log-transformation
sum(is.infinite(data$log_PopBio))  
sum(is.na(data$log_PopBio))  

# combine four columns into a unique ID, split into multiple sub-datasets
subdatasets <- data %>%
  mutate(ID = paste(Species, Medium, Temp, Citation, sep = "_")) %>%
  mutate(ID = as.integer(factor(ID, levels = unique(ID)))) %>%
  group_by(ID) %>%
  group_split()
print(subdatasets) # view the subdatasets


### Model fitting part

## fit the cubic growth model
fit_results_cubic <- lapply(subdatasets, function(subset_data) {
  tryCatch({
    # use linear regression method to fit the model
    curve_model <- lm(PopBio ~ poly(Time, 3, raw = TRUE), data = subset_data)
    
    # calculate the R^2
    Rsq <- summary(curve_model)$r.squared
    
    if (Rsq > 0.7) {  # set a filter value
      return(curve_model)
    } else {
      return(NULL)
    }
  }, error = function(e) {
    return(NULL)
  })
})

# obtain the valid results
valid_results_cubic <- Filter(function(x) !is.null(x) && inherits(x, "lm"), fit_results_cubic)

# calculate the number of successful times to get a simple view
num_successful_fits_cubic <- length(valid_results_cubic)
print(paste("Cubic Linear Fit Success:", num_successful_fits_cubic, "out of", length(subdatasets)))


#  define R^2 - fit quality check
fit_quality <- function(fit, data) {
  if(is.null(fit)) return(NA)
  
  predicted <- predict(fit, newdata = data)
  residuals <- data$PopBio - predicted
  RSS <- sum(residuals^2)
  TSS <- sum((data$PopBio - mean(data$PopBio))^2)
  Rsq <- 1 - (RSS / TSS)  
  return(Rsq)
}

## fit the logistic growth model
# define the logistic growth function
logistic_growth <- function(Time, K, r ,N0) {
  return(K / (1 + ((K - N0) / N0) * exp(-r * Time)))
}

# fit the model
fit_results_logistic <- lapply(subdatasets, function(subset_data) {
  # define the intrinsic growth rate function
  estimate_initial_values <- function(Time, PopBio) {
    growth_rates <- diff(subset_data$PopBio) / diff(subset_data$Time)
    window_size <- max(1, floor(0.2 * length(Time)))
    early_phase <- 1:min(window_size, length(growth_rates))
    r_init <- max(growth_rates[early_phase], na.rm = TRUE)
    
    return(r_init)
  }
  # set the starting values for the parameters
  K_init <- max(subset_data$PopBio, na.rm = TRUE) * 1.2
  N0_init <- min(subset_data$PopBio, na.rm = TRUE)
  r_init <- estimate_initial_values(subset_data$Time, subset_data$PopBio)
  
  # add a certain range of stochastic disturbances based on previous reasonable assumptions
  set.seed(1234 ) # set the seed
  r_init_samples <- rnorm(10, mean = r_init, sd = 0.05)  # random sampling
  K_samples <- rnorm(10, mean = K_init, sd = K_init * 0.05)  # random sampling 
  K_samples[K_samples < max(subset_data$PopBio)] <- max(subset_data$PopBio) # to ensure the random samples are larger thatn the maximum popbio value
  N0_samples <- rep(N0_init, 10) # N0 keeps the same
  
  # the outputs
  best_fit <- NULL
  max_Rsq <- -Inf
  
  # using the nlslm model
  for(i in 1:10) {
  tryCatch({
    fit_logistic <- nlsLM(PopBio ~ logistic_growth(Time, K, r, N0),
                          data = subset_data,
                          start = list(K = K_samples[i], r = r_init_samples[i], N0 = N0_samples[i]), 
                          control = nls.lm.control(maxiter = 500))
    
    Rsq <- fit_quality(fit_logistic, subset_data)
    
    # chosing the model with highest R^2
    if (Rsq > max_Rsq) {       
      max_Rsq <- Rsq       
      best_fit <- fit_logistic }   
   }, error = function(e) { return(NULL) })   
  }   
  # also set a fliter here
    if (!is.null(best_fit) && max_Rsq > 0.7) {
      return(best_fit)
    } else {return(NULL)}
  })
# obtain the valid logistic model results
valid_results_logistic <- Filter(function(x) !is.na(x) && inherits(x, "nls"), fit_results_logistic)

# calculate the number of successful times to get a simple view
num_successful_fits_logistic <- length(valid_results_logistic)
print(paste("Success:", num_successful_fits_logistic, "out of", length(subdatasets)))

## fit the gompertz model
# define the gompertz function
gompertz_model <- function(t, K, r_max, t_lag) {
  return(K * exp(-exp((r_max * exp(1) / K) * (t_lag - t) + 1)))
}

fit_results_gompertz <- lapply(subdatasets, function(subset_data) {
  # to estimate the initial intrinsic value and lag time 
  estimate_initial_values <- function(Time, PopBio) {
    # calculate the first derivative
    growth_rates <- diff(subset_data$PopBio) / diff(subset_data$Time) 
    time_midpoints <- Time[-1] # calculate the point in time corresponding to the first derivative
    
    # calculate the second derivative
    second_derivative <- diff(growth_rates) / diff(time_midpoints[-1])
    time_second_deriv <- time_midpoints[-length(time_midpoints)] # calculate the point in time corresponding to the second derivative
    max_curvature_idx <- which.max(second_derivative)
    r_init <- max(growth_rates, na.rm = TRUE)  # estimate the r_max
    t_lag_init <- time_second_deriv[max_curvature_idx] # estimate the time lag

    return(list(r_max = r_init, t_lag = t_lag_init))
  }
  
  # set the starting values for the parameters
  K_init <- max(subset_data$PopBio, na.rm = TRUE)  
  init_vals <- estimate_initial_values(subset_data$Time, subset_data$PopBio)
  r_max_init <- init_vals$r_max
  t_lag_init <- init_vals$t_lag
  
  # set the seeds to ensure randomness as logistic growth model
  set.seed(1234)
  r_max_samples <- rnorm(10, mean = r_max_init, sd = 0.05)  
  K_samples <- rnorm(10, mean = K_init * 1.2, sd = 0.05)  
  K_samples[K_samples < max(subset_data$PopBio)] <- max(subset_data$PopBio)  
  t_lag_samples <- rnorm(10, mean = t_lag_init, sd = 1) # allow t_lag to fluctuate
  
  best_fit <- NULL
  max_Rsq <- -Inf
  
  # using the same nlsLM method as logistic growth model
  for (i in 1:10) {
  tryCatch({
    fit_gompertz <- nlsLM(
      PopBio ~ gompertz_model(Time, K, r_max, t_lag),
      data = subset_data,
      start = list(K = K_samples[i], r_max = r_max_samples[i], t_lag = t_lag_samples[i]),
      control = nls.lm.control(maxiter = 500))
    
    if (!is.null(fit_gompertz)) { 
      Rsq <- fit_quality(fit_gompertz, subset_data)    
      if (Rsq > max_Rsq) { max_Rsq <- Rsq; best_fit <- fit_gompertz } 
    }
  }, error = function(e) { return(NULL) })   
  }   
  
  if (!is.null(best_fit) && max_Rsq > 0.7) {  
    return(best_fit)   
  } else {     
    return(NULL)   
  } 
})  

# obtain the valid gompertz results
valid_results_gompertz <- Filter(function(x) !is.null(x) && inherits(x, "nls"), fit_results_gompertz)

# calculate the successful times
num_successful_fits_gompertz <- length(valid_results_gompertz)
print(paste("Success:", num_successful_fits_gompertz, "out of", length(subdatasets)))

## plot part

# choose a specific plot to see the visulization of fit
subset_id <- 35  # random choose based on previous observation
data_subset <- subdatasets[[subset_id]]  

# generate three fit model
plot_model_fits <- function(data_subset, fit_results_cubic, fit_results_logistic, fit_results_gompertz, subset_id) {
  # include time oder
  time_order <- order(data_subset$Time)
  time_sorted <- data_subset$Time[time_order]
  
  # generate prediction for every model
  predicted_cubic <- tryCatch(
    predict(fit_results_cubic[[subset_id]], newdata = data.frame(Time = time_sorted)),
    error = function(e) return(NULL)
  )
  
  predicted_logistic <- tryCatch(
    predict(fit_results_logistic[[subset_id]], newdata = data.frame(Time = time_sorted)),
    error = function(e) return(NULL)
  )
  
  predicted_gompertz <- tryCatch(
    predict(fit_results_gompertz[[subset_id]], newdata = data.frame(Time = time_sorted)),
    error = function(e) return(NULL)
  )
  
  # check if there is any model that cannot be predicted
  if (is.null(predicted_cubic) | is.null(predicted_logistic) | is.null(predicted_gompertz)) {
    message(paste("Subset", subset_id, "fall!"))
    return(NULL)
  }
  
  # draw the origin data plot
  plot(
    x = data_subset$Time,
    y = data_subset$PopBio,
    main = paste("Model Fits - Subset", subset_id),
    xlab = "Time",
    ylab = "Population",
    pch = 19,
    col = "black",
    cex = 1.2
  )
  
  # add the fitting line
  lines(
    x = time_sorted,
    y = predicted_cubic,
    col = "red",  # Cubic model in red
    lwd = 2
  )
  lines(
    x = time_sorted,
    y = predicted_logistic,
    col = "blue",  # Logistic model in blue
    lwd = 2
  )
  lines(
    x = time_sorted,
    y = predicted_gompertz,
    col = "green",  # Gompertz model in green
    lwd = 2
  )
  
  # add legend
  legend(
    "bottomright",
    legend = c("Observed", "Cubic Fitted", "Logistic Fitted", "Gompertz Fitted"),
    col = c("black", "red", "blue", "green"),
    pch = c(19, NA, NA, NA),
    lty = c(NA, 1, 1, 1),
    lwd = 2
  )
}

# choose the fitted model for each type
fit_model_cubic <- valid_results_cubic[[subset_id]]
fit_model_logistic <- valid_results_logistic[[subset_id]]
fit_model_gompertz <- valid_results_gompertz[[subset_id]]

# plot the final result
plot_model_fits(data_subset, fit_results_cubic, fit_results_logistic, fit_results_gompertz, subset_id)


### Model selection
# create a list to store the results of model comparisons
results_list <- vector("list", length(subdatasets))

# iterate over each subdatasets
for (i in seq_along(subdatasets)) {
  tryCatch({
    subset_data <- subdatasets[[i]]
    dataset_id <- unique(subset_data$ID)[1]
  
 # initialize R^2, AIC, BIC
  cubic_R2 <- logistic_R2 <- gompertz_R2 <-NA
  cubic_AIC <- logistic_AIC <- gompertz_AIC <- NA
  cubic_BIC <- logistic_BIC <- gompertz_BIC <- NA

  
  # calculate the R^2, AIC, BIC for the cubic model
  if (i <= length(fit_results_cubic) && !is.null(fit_results_cubic[[i]]) && inherits(fit_results_cubic[[i]], "lm")) {
    cubic_model <- fit_results_cubic[[i]]
    cubic_R2 <- summary(cubic_model)$r.squared
    RSS <- sum(residuals(cubic_model)^2)
    n <- nrow(subset_data)
    k <- length(coef(cubic_model))
    if (RSS > 0) {
      cubic_AIC <- n * log(RSS / n) + 2 * k
      cubic_BIC <- n * log(RSS / n) + log(n) * k
    }
  }
  
  # calculate the R^2, AIC, BIC for the logistic model
  if (i <= length(fit_results_logistic) && !is.null(fit_results_logistic[[i]]) && inherits(fit_results_logistic[[i]], "nls")) {
    logistic_model_results <- fit_results_logistic[[i]]
    predicted <- predict(logistic_model_results)
    residuals <- subset_data$PopBio - predicted
    RSS <- sum(residuals^2)
    TSS <- sum((subset_data$PopBio - mean(subset_data$PopBio))^2)
    logistic_R2 <- 1 - (RSS / TSS)
    n <- nrow(subset_data)
    k <- length(coef(logistic_model_results))
    if (RSS > 0) {
      logistic_AIC <- n * log(RSS / n) + 2 * k
      logistic_BIC <- n * log(RSS / n) + log(n) * k
    }
  }
  
  # calculate the R^2, AIC, BIC for the gompertz model
  if (i <= length(fit_results_gompertz) && !is.null(fit_results_gompertz[[i]]) && inherits(fit_results_gompertz[[i]], "nls")) {
    gompertz_model_results <- fit_results_gompertz[[i]]
    predicted <- predict(gompertz_model_results)
    residuals <- subset_data$PopBio - predicted
    RSS <- sum(residuals^2)
    TSS <- sum((subset_data$PopBio - mean(subset_data$PopBio))^2)
    gompertz_R2 <- 1 - (RSS / TSS)
    n <- nrow(subset_data)
    k <- length(coef(gompertz_model_results))
    if (RSS > 0) {
      gompertz_AIC <- n * log(RSS / n) + 2 * k
      gompertz_BIC <- n * log(RSS / n) + log(n) * k
    }
  }
  
  # choose the best model
  best_model_R2 <- names(which.max(na.omit(c(Cubic = cubic_R2, Logistic = logistic_R2, Gompertz = gompertz_R2))))
  best_model_AIC <- names(which.min(na.omit(c(Cubic = cubic_AIC, Logistic = logistic_AIC, Gompertz = gompertz_AIC))))
  best_model_BIC <- names(which.min(na.omit(c(Cubic = cubic_BIC, Logistic = logistic_BIC, Gompertz = gompertz_BIC))))
  

  # save the results
  results_list[[i]] <- data.frame(
    ID = dataset_id, 
    Cubic_R2 = cubic_R2, Logistic_R2 = logistic_R2, Gompertz_R2 = gompertz_R2,
    Cubic_AIC = cubic_AIC, Logistic_AIC = logistic_AIC, Gompertz_AIC = gompertz_AIC,
    Cubic_BIC = cubic_BIC, Logistic_BIC = logistic_BIC, Gompertz_BIC = gompertz_BIC,
    Best_Model_R2 = best_model_R2, Best_Model_AIC = best_model_AIC, Best_Model_BIC = best_model_BIC,
    stringsAsFactors = FALSE
  )
  }, error = function(e) { results_list[[i]] <- NULL })
}
# combine all the results
model_comparison <- do.call(rbind, Filter(Negate(is.null), results_list))
if (nrow(model_comparison) > 0) {
write.csv(model_comparison, "model_comparison_results_with_AIC_BIC.csv", row.names = FALSE)
print(model_comparison)

# count the number of each best model
  model_counts_R2 <- table(model_comparison$Best_Model_R2)
  print(model_counts_R2)
  model_counts_AIC <- table(model_comparison$Best_Model_AIC)
  print(model_counts_AIC)
  model_counts_BIC <- table(model_comparison$Best_Model_BIC)
  print(model_counts_BIC)
  
# Create a summary table with counts
  summary_table <- data.frame(
    Model = c("Cubic", "Gompertz", "Logistic"),
    R2_Count = c(model_counts_R2["Cubic"], model_counts_R2["Gompertz"], model_counts_R2["Logistic"]),
    AIC_Count = c(model_counts_AIC["Cubic"], model_counts_AIC["Gompertz"], model_counts_AIC["Logistic"]),
    BIC_Count = c(model_counts_BIC["Cubic"], model_counts_BIC["Gompertz"], model_counts_BIC["Logistic"])
  )
  
  # Print the summary table
  print(summary_table)
  
  # Optionally save the summary table as a CSV
  write.csv(summary_table, "model_comparison_summary.csv", row.names = FALSE)
  
} else {
  print("Warning: No valid model results to analyze or save.")
}



