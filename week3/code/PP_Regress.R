rm(list = ls())
 
library(dplyr)
library(ggplot2)
library(tidyr)
 
# read in data
Data <- read.csv("../data/EcolArchives-E089-51-D1.csv")
head(Data)
 
# create a plot present the relationship between prey mass and predator mass
p <- ggplot(Data, aes(x = Prey.mass, y = Predator.mass, color = Predator.lifestage)) +
    geom_point(shape = 3, alpha = 1) +  
    geom_smooth(method = "lm", se = TRUE, linewidth = 0.8, fullrange = TRUE) +  # add the appropriate regression line
    scale_x_log10(breaks = c(1e-07, 1e-03, 1e+01),
                  expand = c(0.1, 0)) +  # adjust the x-axis using a logarithmic scale
    scale_y_log10(breaks = c(1e-06, 1e-02, 1e+02, 1e+06),
                  expand = c(0.1, 0)) +  # adjust the y-axis using a logarithmic scale
    facet_wrap(~ Type.of.feeding.interaction, scales = "fixed", ncol = 1, strip.position = "right") +  # facet by feeding interaction
    labs(
      x = "Prey Mass in grams",
      y = "Predator Mass in grams",
      color = "Predator Lifestage"
    ) +
  #customize the plot appearance and layout
    theme_minimal() +  
    theme(
      strip.text = element_text(size = 12, face = "bold"),
      strip.background = element_rect(fill = "grey", color = "black"),  
      panel.border = element_rect(color = "grey", fill = NA, linewidth = 0.5),
      legend.position = "bottom"  
    ) 
 
# save the plot as a pdf file
pdf(file = "../results/PP_Regress_Figure.pdf", width = 10, height = 20)
print(p)
dev.off
 
 
# do the regression analysis corresponding to the figure
regression_model <- Data %>%
  group_by(Type.of.feeding.interaction, Predator.lifestage) %>% # subset the data by type of feeding interaction and predator lifestage
  group_modify(~ {
    # check if regression can be performed
    if (nrow(.x) < 2 || var(.x$Prey.mass, na.rm = TRUE) == 0 || var(.x$Predator.mass, na.rm = TRUE) == 0) {
      return(data.frame(
        slope = NA,
        intercept = NA,
        r_squared = NA,
        f_statistic = NA,
        p_value = NA
      ))
    }
    model <- lm(Predator.mass ~ Prey.mass, data = .x) # Fit a linear regression model
    data.frame(
      slope = coef(model)[2],  # extract slope
      intercept = coef(model)[1], # intercept
      r_squared = summary(model)$r.squared, # R²
      f_statistic = summary(model)$fstatistic[1], # F-statistic
      p_value = summary(model)$coefficients[2, 4] # p-value
    )
  }) 
 
# save the result to csv delimited table
write.csv(regression_model, file = "../results/PP_Regress_Results.csv", row.names = FALSE)