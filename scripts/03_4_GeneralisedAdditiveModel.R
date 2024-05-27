--------------------------------------------------------------------------------
  
# Generalised Additive Model
  
--------------------------------------------------------------------------------

# Install libraries

library(readr)
library(readxl)
library(ggplot2)
library(mgcv)
library(dplyr)
library(caret)

--------------------------------------------------------------------------------

# Load necessary libraries

# Reading in data
d.properties <- read_excel("data/data_cleaned/data_total_model.xlsx")
str(d.properties)
head(d.properties)

--------------------------------------------------------------------------------
# Plotting data
gg.density.site <- ggplot(data = d.properties, mapping = aes(y = Price_Gross, x = Size_m2)) + 
  geom_point()

gg.density.site + geom_smooth()

--------------------------------------------------------------------------------
# Fit a basic linear model
lm.properties.1 <- lm(Price_Gross ~ Size_m2, data = d.properties)
summary(lm.properties.1)

# p-value (Pr(>|t|)): < 2e-16, indicating very high significance (p < 0.001).
# Multiple R-squared: 0.08348. This suggests that approximately 8.35% of the variability in Price_Gross can be explained by Size_m2.

--------------------------------------------------------------------------------
  
# Fit a quadratic model
lm.properties.2 <- lm(Price_Gross ~ poly(Size_m2, 2), data = d.properties)
summary(lm.properties.2)

--------------------------------------------------------------------------------
  
# Compare linear and quadratic models
anova(lm.properties.1, lm.properties.2)

# Interpretation of the ANOVA table:
# Residual Degrees of Freedom (Res.Df): The quadratic model has one less degree of freedom than the linear model, indicating an additional parameter (the quadratic term).
# Residual Sum of Squares (RSS): The quadratic model has a lower RSS (946,506,359) compared to the linear model (1,080,715,226), indicating a better fit.
# Reduction in RSS: The improvement in fit by including the quadratic term is 134,208,867.
# F-statistic: A value of 136.41 indicates a significant improvement in fit.
# p-value: A p-value of < 2.2e-16 shows that the improvement is highly significant, indicating that the relationship between Size_m2 and Price_Gross includes a significant quadratic component.

# Conclusion:
# The comparison between the linear model (Price_Gross ~ Size_m2) and the quadratic model (Price_Gross ~ poly(Size_m2, 2)) shows that adding the quadratic term significantly improves the model fit. This suggests that the relationship between Size_m2 and Price_Gross is not simply linear, but has a significant quadratic component.

--------------------------------------------------------------------------------
  
# Next Steps:
# Given that the quadratic term is significant, the next steps would be:
# - Consider higher-order polynomial terms to see if a cubic or other relationship can provide a better fit.
# - Fit a GAM (Generalized Additive Model) to capture more complex non-linear relationships.
# - Include other predictor variables in the model to see how they affect the gross property price.

# Visualize the quadratic fit
gg.density.site + geom_smooth(method = "lm", formula = y ~ poly(x, degree = 2))

--------------------------------------------------------------------------------
# Fit a GAM
gam.properties <- gam(Price_Gross ~ s(Size_m2), data = d.properties)
summary(gam.properties)

# Visualize the GAM fit
plot(gam.properties, residuals = TRUE, cex = 2)

# Recommendations:
# - Focus on the Relevant Range: When making predictions or analyses about Price_Gross, it is safer to focus on properties up to 250 m², where the model is more reliable.
# - Collect More Data: If it is important to understand price behavior for larger properties, consider collecting more data in that range to improve model accuracy.
# - Model Validation: Validate the model using techniques such as cross-validation to ensure the fit is adequate in the range where there are more data.
# - Alternative Models: Consider other models that can better handle the scarcity of data in the larger property region or use regularization techniques that can help improve model stability in the presence of high variance.

--------------------------------------------------------------------------------
  
# Fit a GAM with multiple predictors
gam.properties.full <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density, data = d.properties)
summary(gam.properties.full)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.full, residuals = TRUE, cex = 2)

# Model Fit Measures:
# Adjusted R-squared: 0.413 (41.3% of the variability in Price_Gross explained by the model)
# Deviance explained: 41.9%
# GCV (Generalized Cross-Validation score): 726,970
# Scale estimation: 718,570
# Number of Observations (n): 965

# Conclusion:
# - Model Significance: The terms Days_Difference and Nr_rooms are highly significant. GDP_per and Population are moderately significant. Area_km2 and Density are not significant. The smooth term s(Size_m2) is highly significant and captures an important non-linear relationship.
# - Model Flexibility: The smooth term s(Size_m2) has an edf of 5.146, suggesting sufficient flexibility to capture the non-linear relationship between Size_m2 and Price_Gross.
# - Goodness of Fit: The adjusted R-squared of 0.413 indicates that the model explains approximately 41.3% of the variability in property prices, which is a considerable improvement over simpler models.

--------------------------------------------------------------------------------
  
# Filter data to include only properties with Size_m2 < 300
d.properties.filtered <- d.properties %>% filter(Size_m2 < 300)

# Fit the GAM with filtered data
gam.properties.filtered <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density, data = d.properties.filtered)

# Summary of the filtered model
summary(gam.properties.filtered)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.filtered, residuals = TRUE, cex = 2)

--------------------------------------------------------------------------------
  

# Transform the Size_m2 variable
d.properties <- d.properties %>% mutate(log_Size_m2 = log(Size_m2))

# Fit the GAM with the transformed variable
gam.properties.log <- gam(Price_Gross ~ s(log_Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density, data = d.properties)

# Summary of the model with the log transformation
summary(gam.properties.log)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.log, residuals = TRUE, cex = 2)

--------------------------------------------------------------------------------

# Fit the GAM with interactions
gam.properties.interaction <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by=Nr_rooms), data = d.properties)

# Summary of the model with interactions
summary(gam.properties.interaction)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.interaction, residuals = TRUE, cex = 2)

--------------------------------------------------------------------------------

# Filter data for Size_m2 < 300
d.properties.filtered <- d.properties %>% filter(Size_m2 < 300)

# Transform the Size_m2 variable
d.properties.filtered <- d.properties.filtered %>% mutate(log_Size_m2 = log(Size_m2))

# Fit the GAM with the transformed variable and interaction
gam.properties.combined <- gam(Price_Gross ~ s(log_Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = d.properties.filtered)

# Summary of the combined model
summary(gam.properties.combined)

# Visualize the smooth term
par(mfrow = c(2, 2))
plot(gam.properties.combined, residuals = TRUE, cex = 2)

--------------------------------------------------------------------------------
# Train Best model: GAM with interaction
  
# Define the number of folds for cross-validation
set.seed(123)
folds <- createFolds(d.properties$Price_Gross, k = 10, list = TRUE)

# Initialize a vector to store RMSE values for each fold
rmse_values <- c()

# Perform cross-validation
for(i in 1:length(folds)) {
  # Split the data into training and testing sets
  test_indices <- folds[[i]]
  train_data <- d.properties[-test_indices, ]
  test_data <- d.properties[test_indices, ]
  
  # Fit the model on the training data
  gam_model <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = train_data)
  
  # Predict on the test data
  predictions <- predict(gam_model, newdata = test_data)
  
  # Calculate RMSE for the current fold
  rmse <- sqrt(mean((predictions - test_data$Price_Gross)^2))
  rmse_values <- c(rmse_values, rmse)
}

# Calculate the average RMSE across all folds
average_rmse <- mean(rmse_values)

# Print the average RMSE
print(average_rmse)

# Fit the GAM model on the entire dataset
gam_model_final <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = d.properties)

# Summary of the final model
summary(gam_model_final)

# Generate a new dataset with Size_m2 between 50 and 500 m²
set.seed(123)
new_data <- data.frame(
  Size_m2 = seq(50, 500, length.out = 500),
  Days_Difference = sample(d.properties$Days_Difference, 500, replace = TRUE),
  Nr_rooms = sample(d.properties$Nr_rooms, 500, replace = TRUE),
  GDP_per = sample(d.properties$GDP_per, 500, replace = TRUE),
  Population = sample(d.properties$Population, 500, replace = TRUE),
  Area_km2 = sample(d.properties$Area_km2, 500, replace = TRUE),
  Density = sample(d.properties$Density, 500, replace = TRUE)
)

# Predict the price for the new data
predicted_prices <- predict(gam_model_final, newdata = new_data)

# Add the predictions to the new_data dataframe
new_data <- new_data %>%
  mutate(Predicted_Price = predicted_prices)

# Preview the new dataset with predictions
head(new_data)

# Plot the predictions
ggplot(test_data, aes(x = Size_m2, y = Predicted_Price)) +
  geom_line(color = "blue") +
  labs(title = "Predicted Prices vs. Size_m2", x = "Size (m²)", y = "Predicted Price (Gross)") +
  theme_minimal()


# Plot the predictions
ggplot(new_data, aes(x = Size_m2, y = Predicted_Price)) +
  geom_line(color = "blue") +
  labs(title = "Predicted Prices vs. Size_m2", x = "Size (m²)", y = "Predicted Price (Gross)") +
  theme_minimal()

--------------------------------------------------------------------------------
  

# Define the number of folds for cross-validation
set.seed(123)
folds <- createFolds(d.properties$Price_Gross, k = 10, list = TRUE)

# Initialize vectors to store predictions and actual prices
all_predictions <- c()
all_actuals <- c()  

# Perform cross-validation
for(i in 1:length(folds)) {
  # Split the data into training and testing sets
  test_indices <- folds[[i]]
  train_data <- d.properties[-test_indices, ]
  test_data <- d.properties[test_indices, ]
  
  # Fit the model on the training data
  gam_model <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = train_data)
  
  # Predict on the test data
  predictions <- predict(gam_model, newdata = test_data)
  
  # Store the predictions and actual values
  all_predictions <- c(all_predictions, predictions)
  all_actuals <- c(all_actuals, test_data$Price_Gross)
  
  # Calculate RMSE for the current fold
  rmse <- sqrt(mean((predictions - test_data$Price_Gross)^2))
  rmse_values <- c(rmse_values, rmse)
}

# Calculate the average RMSE across all folds
average_rmse <- mean(rmse_values)

# Print the average RMSE
print(average_rmse)

# Create a data frame with predictions and actual values
results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals)

# Create an index for each test instance
results_df <- results_df %>%
  mutate(Index = 1:nrow(results_df))

# Plot the predicted vs. actual prices as lines
line_plot <- ggplot(results_df, aes(x = Index)) +
  geom_line(aes(y = Actual, color = "Actual Price"), size = 0.3, alpha = 0.7) +
  geom_line(aes(y = Predicted, color = "Predicted Price"), size = 0.7, linetype = "dashed", alpha = 0.7) +
  labs(title = "Comparison of Predicted and Actual Prices",
       subtitle = paste("Average RMSE across 10 folds:", round(average_rmse, 2)),
       x = "Index",
       y = "Price (Gross)",
       color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Actual Price" = "grey", "Predicted Price" = "#9C8AE6")) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )

# Limit the data to properties with sizes up to 500 m²
limited_data <- d.properties %>%
  filter(Size_m2 <= 500)

# Initialize vectors to store predictions and actual prices for limited data
limited_predictions <- c()
limited_actuals <- c()

# Perform cross-validation for limited data
for(i in 1:length(folds)) {
  # Split the data into training and testing sets
  test_indices <- folds[[i]]
  train_data <- limited_data[-test_indices, ]
  test_data <- limited_data[test_indices, ]
  
  # Fit the model on the training data
  gam_model <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = train_data)
  
  # Predict on the test data
  predictions <- predict(gam_model, newdata = test_data)
  
  # Store the predictions and actual values
  limited_predictions <- c(limited_predictions, predictions)
  limited_actuals <- c(limited_actuals, test_data$Price_Gross)
}

# Create a data frame with predictions and actual values for limited data
limited_results_df <- data.frame(Predicted = limited_predictions, Actual = limited_actuals)

# Combine the predicted and actual prices into a single column for plotting
long_results_df <- limited_results_df %>%
  pivot_longer(cols = c("Predicted", "Actual"), names_to = "Type", values_to = "Price")

# Plot box plots of the predicted and actual prices
box_plot <- ggplot(long_results_df, aes(x = Type, y = Price, fill = Type)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Distribution of Predicted and Actual Prices for Properties ≤ 500m²",
       x = "Type",
       y = "Price (Gross)") +
  scale_fill_manual(values = c("Actual" = "grey", "Predicted" = "#9C8AE6")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "none"
  )

# Combine both plots into one figure
grid.arrange(line_plot, box_plot, ncol = 2)


# Plot the predicted vs. actual prices as lines
line_plot <- ggplot(results_df, aes(x = Index)) +
  geom_line(aes(y = Actual, color = "Actual Price"), size = 0.3, alpha = 0.7) +
  geom_line(aes(y = Predicted, color = "Predicted Price"), size = 0.7, linetype = "dashed", alpha = 0.7) +
  labs(title = "Comparison of Predicted and Actual Prices for Properties ≤ 500m²",
       subtitle = paste("Average RMSE across 10 folds:", round(average_rmse, 2)),
       x = "Index",
       y = "Price (Gross)",
       color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Actual Price" = "grey", "Predicted Price" = "#9C8AE6")) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    legend.position = "top"
  )

------
  
  
  # Load necessary libraries
  library(mgcv)
library(dplyr)
library(caret)
library(ggplot2)
library(tidyr)
library(gridExtra)

# Define the number of folds for cross-validation
set.seed(123)
folds <- createFolds(d.properties$Price_Gross, k = 10, list = TRUE)

# Initialize vectors to store predictions and actual prices for limited data
all_predictions <- c()
all_actuals <- c()
all_size_m2 <- c()

# Perform cross-validation for limited data
for(i in 1:length(folds)) {
  # Split the data into training and testing sets
  test_indices <- folds[[i]]
  train_data <- d.properties[-test_indices, ]
  test_data <- d.properties[test_indices, ]
  
  # Fit the model on the training data
  gam_model <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = train_data)
  
  # Predict on the test data
  predictions <- predict(gam_model, newdata = test_data)
  
  # Filter predictions, actual values, and Size_m2 to Size_m2 <= 500
  limited_predictions <- predictions[test_data$Size_m2 <= 500]
  limited_actuals <- test_data$Price_Gross[test_data$Size_m2 <= 500]
  limited_size_m2 <- test_data$Size_m2[test_data$Size_m2 <= 500]
  
  # Store the filtered predictions, actual values, and Size_m2
  all_predictions <- c(all_predictions, limited_predictions)
  all_actuals <- c(all_actuals, limited_actuals)
  all_size_m2 <- c(all_size_m2, limited_size_m2)
  
  # Calculate RMSE for the current fold
  rmse <- sqrt(mean((limited_predictions - limited_actuals)^2))
  rmse_values <- c(rmse_values, rmse)
}

# Calculate the average RMSE across all folds
average_rmse <- mean(rmse_values)

# Print the average RMSE
print(average_rmse)

# Create a data frame with predictions, actual values, and Size_m2
results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals, Size_m2 = all_size_m2)

# Bin the data by Size_m2 with steps of 10 m² and calculate mean prices for each bin
results_df <- results_df %>%
  mutate(Size_m2_bin = cut(Size_m2, breaks = seq(0, 500, by = 10), include.lowest = TRUE, right = FALSE)) %>%
  group_by(Size_m2_bin) %>%
  summarize(mean_predicted = mean(Predicted), mean_actual = mean(Actual)) %>%
  mutate(Size_m2_bin = as.numeric(gsub("[^0-9]", "", as.character(Size_m2_bin))))

# Plot the binned mean predicted vs. actual prices
line_plot <- ggplot(results_df, aes(x = Size_m2_bin)) +
  geom_line(aes(y = mean_actual, color = "Actual Price"), size = 0.7, alpha = 0.7) +
  geom_line(aes(y = mean_predicted, color = "Predicted Price"), size = 0.7, linetype = "dashed", alpha = 0.7) +
  labs(title = "Comparison of Predicted and Actual Prices for Properties ≤ 500m²",
       subtitle = paste("Average RMSE across 10 folds:", round(average_rmse, 2)),
       x = "Size (m²)",
       y = "Price (Gross)",
       color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Actual Price" = "grey", "Predicted Price" = "#9C8AE6")) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    legend.position = "top"
  )

# Create a data frame with predictions and actual values for limited data
limited_results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals)

# Combine the predicted and actual prices into a single column for plotting
long_results_df <- limited_results_df %>%
  pivot_longer(cols = c("Predicted", "Actual"), names_to = "Type", values_to = "Price")

# Plot box plots of the predicted and actual prices
box_plot <- ggplot(long_results_df, aes(x = Type, y = Price, fill = Type)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Distribution of Predicted and Actual Prices for Properties ≤ 500m²",
       x = "Type",
       y = "Price (Gross)") +
  scale_fill_manual(values = c("Actual" = "grey", "Predicted" = "#9C8AE6")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "none"
  )

# Combine both plots into one figure
grid.arrange(line_plot, box_plot, ncol = 2)

---------
  
  
  # Load necessary libraries
  library(mgcv)
library(dplyr)
library(caret)
library(ggplot2)
library(tidyr)
library(gridExtra)

# Define the number of folds for cross-validation
set.seed(123)
folds <- createFolds(d.properties$Price_Gross, k = 10, list = TRUE)

# Initialize vectors to store predictions and actual prices for limited data
all_predictions <- c()
all_actuals <- c()
all_size_m2 <- c()

# Perform cross-validation for limited data
for(i in 1:length(folds)) {
  # Split the data into training and testing sets
  test_indices <- folds[[i]]
  train_data <- d.properties[-test_indices, ]
  test_data <- d.properties[test_indices, ]
  
  # Fit the model on the training data
  gam_model <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = train_data)
  
  # Predict on the test data
  predictions <- predict(gam_model, newdata = test_data)
  
  # Filter predictions, actual values, and Size_m2 to Size_m2 <= 500
  limited_predictions <- predictions[test_data$Size_m2 <= 500]
  limited_actuals <- test_data$Price_Gross[test_data$Size_m2 <= 500]
  limited_size_m2 <- test_data$Size_m2[test_data$Size_m2 <= 500]
  
  # Store the filtered predictions, actual values, and Size_m2
  all_predictions <- c(all_predictions, limited_predictions)
  all_actuals <- c(all_actuals, limited_actuals)
  all_size_m2 <- c(all_size_m2, limited_size_m2)
  
  # Calculate RMSE for the current fold
  rmse <- sqrt(mean((limited_predictions - limited_actuals)^2))
  rmse_values <- c(rmse_values, rmse)
}

# Calculate the average RMSE across all folds
average_rmse <- mean(rmse_values)

# Print the average RMSE
print(average_rmse)

# Create a data frame with predictions, actual values, and Size_m2
results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals, Size_m2 = all_size_m2)

# Bin the data by Size_m2 with steps of 10 m² and calculate mean prices for each bin
results_df <- results_df %>%
  mutate(Size_m2_bin = cut(Size_m2, breaks = seq(0, 500, by = 10), include.lowest = TRUE, right = FALSE)) %>%
  group_by(Size_m2_bin) %>%
  summarize(mean_predicted = mean(Predicted), mean_actual = mean(Actual)) %>%
  mutate(Size_m2_bin = as.numeric(gsub("[^0-9]", "", as.character(Size_m2_bin))))

# Plot the binned mean predicted vs. actual prices
line_plot <- ggplot(results_df, aes(x = Size_m2_bin)) +
  geom_line(aes(y = mean_actual, color = "Actual Price"), size = 0.7, alpha = 0.7) +
  geom_line(aes(y = mean_predicted, color = "Predicted Price"), size = 0.7, linetype = "dashed", alpha = 0.7) +
  scale_x_continuous(breaks = seq(0, 500, by = 50)) +
  labs(title = "Comparison of Predicted and Actual Prices for Properties ≤ 500m²",
       subtitle = paste("Average RMSE across 10 folds:", round(average_rmse, 2)),
       x = "Size (m²)",
       y = "Price (Gross)",
       color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Actual Price" = "grey", "Predicted Price" = "#9C8AE6")) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    legend.position = "top"
  )

# Create a data frame with predictions and actual values for limited data
limited_results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals)

# Combine the predicted and actual prices into a single column for plotting
long_results_df <- limited_results_df %>%
  pivot_longer(cols = c("Predicted", "Actual"), names_to = "Type", values_to = "Price")

# Plot box plots of the predicted and actual prices
box_plot <- ggplot(long_results_df, aes(x = Type, y = Price, fill = Type)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Distribution of Predicted and Actual Prices for Properties ≤ 500m²",
       x = "Type",
       y = "Price (Gross)") +
  scale_fill_manual(values = c("Actual" = "grey", "Predicted" = "#9C8AE6")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "none"
  )

# Combine both plots into one figure
grid.arrange(line_plot, box_plot, ncol = 2)



-----------
  
  
  # Load necessary libraries
  library(mgcv)
library(dplyr)
library(caret)
library(ggplot2)
library(tidyr)
library(gridExtra)

# Define the number of folds for cross-validation
set.seed(123)
folds <- createFolds(d.properties$Price_Gross, k = 10, list = TRUE)

# Initialize vectors to store predictions and actual prices
all_predictions <- c()
all_actuals <- c()
all_size_m2 <- c()

# Perform cross-validation
for(i in 1:length(folds)) {
  # Split the data into training and testing sets
  test_indices <- folds[[i]]
  train_data <- d.properties[-test_indices, ]
  test_data <- d.properties[test_indices, ]
  
  # Fit the model on the training data
  gam_model <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = train_data)
  
  # Predict on the test data
  predictions <- predict(gam_model, newdata = test_data)
  
  # Store the predictions, actual values, and Size_m2
  all_predictions <- c(all_predictions, predictions)
  all_actuals <- c(all_actuals, test_data$Price_Gross)
  all_size_m2 <- c(all_size_m2, test_data$Size_m2)
  
  # Calculate RMSE for the current fold
  rmse <- sqrt(mean((predictions - test_data$Price_Gross)^2))
  rmse_values <- c(rmse_values, rmse)
}

# Calculate the average RMSE across all folds
average_rmse <- mean(rmse_values)

# Print the average RMSE
print(average_rmse)

# Create a data frame with predictions, actual values, and Size_m2
results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals, Size_m2 = all_size_m2)

# Bin the data by Size_m2 with steps of 10 m² and calculate mean prices for each bin
results_df <- results_df %>%
  mutate(Size_m2_bin = cut(Size_m2, breaks = seq(min(Size_m2), max(Size_m2), by = 10), include.lowest = TRUE, right = FALSE)) %>%
  group_by(Size_m2_bin) %>%
  summarize(mean_predicted = mean(Predicted), mean_actual = mean(Actual)) %>%
  mutate(Size_m2_bin = as.numeric(gsub("[^0-9]", "", as.character(Size_m2_bin))))

# Plot the binned mean predicted vs. actual prices
line_plot <- ggplot(results_df, aes(x = Size_m2_bin)) +
  geom_line(aes(y = mean_actual, color = "Actual Price"), size = 0.7, alpha = 0.7) +
  geom_line(aes(y = mean_predicted, color = "Predicted Price"), size = 0.7, linetype = "dashed", alpha = 0.7) +
  labs(title = "Comparison of Predicted and Actual Prices for All Properties",
       subtitle = paste("Average RMSE across 10 folds:", round(average_rmse, 2)),
       x = "Size (m²)",
       y = "Price (Gross)",
       color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Actual Price" = "grey", "Predicted Price" = "#9C8AE6")) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    legend.position = "top"
  )

# Create a data frame with predictions and actual values
limited_results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals)

# Combine the predicted and actual prices into a single column for plotting
long_results_df <- limited_results_df %>%
  pivot_longer(cols = c("Predicted", "Actual"), names_to = "Type", values_to = "Price")

# Plot box plots of the predicted and actual prices
box_plot <- ggplot(long_results_df, aes(x = Type, y = Price, fill = Type)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Distribution of Predicted and Actual Prices for All Properties",
       x = "Type",
       y = "Price (Gross)") +
  scale_fill_manual(values = c("Actual" = "grey", "Predicted" = "#9C8AE6")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "none"
  )

# Combine both plots into one figure
grid.arrange(line_plot, box_plot, ncol = 2)



# Load necessary libraries
library(mgcv)
library(dplyr)
library(caret)
library(ggplot2)
library(tidyr)
library(gridExtra)

# Define the number of folds for cross-validation
set.seed(123)
folds <- createFolds(d.properties$Price_Gross, k = 10, list = TRUE)

# Initialize vectors to store predictions and actual prices
all_predictions <- c()
all_actuals <- c()
all_size_m2 <- c()

# Perform cross-validation
for(i in 1:length(folds)) {
  # Split the data into training and testing sets
  test_indices <- folds[[i]]
  train_data <- d.properties[-test_indices, ]
  test_data <- d.properties[test_indices, ]
  
  # Fit the model on the training data
  gam_model <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = train_data)
  
  # Predict on the test data
  predictions <- predict(gam_model, newdata = test_data)
  
  # Store the predictions, actual values, and Size_m2
  all_predictions <- c(all_predictions, predictions)
  all_actuals <- c(all_actuals, test_data$Price_Gross)
  all_size_m2 <- c(all_size_m2, test_data$Size_m2)
  
  # Calculate RMSE for the current fold
  rmse <- sqrt(mean((predictions - test_data$Price_Gross)^2))
  rmse_values <- c(rmse_values, rmse)
}

# Calculate the average RMSE across all folds
average_rmse <- mean(rmse_values)

# Print the average RMSE
print(average_rmse)

# Create a data frame with predictions, actual values, and Size_m2
results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals, Size_m2 = all_size_m2)

# Bin the data by Size_m2 with steps of 100 m² and calculate mean prices for each bin
results_df <- results_df %>%
  mutate(Size_m2_bin = cut(Size_m2, breaks = seq(0, max(Size_m2), by = 100), include.lowest = TRUE, right = FALSE)) %>%
  group_by(Size_m2_bin) %>%
  summarize(mean_predicted = mean(Predicted), mean_actual = mean(Actual)) %>%
  mutate(Size_m2_bin = as.numeric(gsub("[^0-9]", "", as.character(Size_m2_bin))))

# Plot the binned mean predicted vs. actual prices
line_plot <- ggplot(results_df, aes(x = Size_m2_bin)) +
  geom_line(aes(y = mean_actual, color = "Actual Price"), size = 0.7, alpha = 0.7) +
  geom_line(aes(y = mean_predicted, color = "Predicted Price"), size = 0.7, linetype = "dashed", alpha = 0.7) +
  scale_x_continuous(breaks = seq(0, max(results_df$Size_m2_bin, na.rm = TRUE), by = 100)) +
  labs(title = "Comparison of Predicted and Actual Prices for All Properties",
       subtitle = paste("Average RMSE across 10 folds:", round(average_rmse, 2)),
       x = "Size (m²)",
       y = "Price (Gross)",
       color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Actual Price" = "grey", "Predicted Price" = "#9C8AE6")) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    legend.position = "top"
  )

# Create a data frame with predictions and actual values
limited_results_df <- data.frame(Predicted = all_predictions, Actual = all_actuals)

# Combine the predicted and actual prices into a single column for plotting
long_results_df <- limited_results_df %>%
  pivot_longer(cols = c("Predicted", "Actual"), names_to = "Type", values_to = "Price")

# Plot box plots of the predicted and actual prices
box_plot <- ggplot(long_results_df, aes(x = Type, y = Price, fill = Type)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Distribution of Predicted and Actual Prices for All Properties",
       x = "Type",
       y = "Price (Gross)") +
  scale_fill_manual(values = c("Actual" = "grey", "Predicted" = "#9C8AE6")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "none"
  )

# Combine both plots into one figure
grid.arrange(line_plot, box_plot, ncol = 2)


----
  
  


    

  