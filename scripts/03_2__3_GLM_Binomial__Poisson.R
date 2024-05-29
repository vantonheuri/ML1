--------------------------------------------------------------------------------
  
# Load libraries
library(readr)
library(ggplot2)
library(stringr)
library(dplyr)
library(readxl)
library(openxlsx)
library(lubridate)
library(mgcv)
library(splines)
library(ROSE)

--------------------------------------------------------------------------------
  
# Read the data from an Excel file and create a binary outcome variable
enc_data <- read_excel("data/data_cleaned/data_total_model.xlsx") %>%
  mutate(fast.sale = ifelse(Days_Difference <= 17, 1, 0))  # Binary outcome: 1 if Days_Difference <= 17, else 0

# Calculate the mean of Days_Difference
mean(enc_data$Days_Difference)

# Split the data into training and testing sets
set.seed(71)
split_ratio <- 0.8
training_indices <- sample(1:nrow(enc_data), size = nrow(enc_data) * split_ratio, replace = FALSE)
train_set <- enc_data[training_indices, ]
test_set <- enc_data[-training_indices, ]

# Fit a binomial logistic regression model to predict fast sale
binomial.model <- glm(fast.sale ~ Price_Gross + Nr_rooms + Size_m2 + Canton_num + Customer_Segment_num + Category_num, 
                      family = binomial, data = train_set)

# Display the summary of the binomial model
summary(binomial.model)

# Calculate and print odds ratios from the model coefficients
coef <- coef(binomial.model)
odds_ratios <- exp(coef)
print(odds_ratios)

# Get and display fitted values (predicted probabilities) for the training set
fitted_values_train <- fitted(binomial.model)
train_set$fitted_values <- fitted_values_train
head(train_set[, c("fast.sale", "fitted_values")])

# Predict probabilities for the test set and display the first few predictions
predicted_probabilities_test <- predict(binomial.model, test_set, type = "response")
test_set$fitted_values <- predicted_probabilities_test
head(test_set[, c("fast.sale", "fitted_values")])

# Convert predicted probabilities to binary outcomes using a 0.5 threshold
predicted_classes <- ifelse(predicted_probabilities_test > 0.5, 1, 0)
actual_classes <- test_set$fast.sale

# Create and print the confusion matrix
conf_matrix <- table(Predicted = predicted_classes, Actual = actual_classes)
conf_matrix_percent <- prop.table(conf_matrix) * 100
print(round(conf_matrix_percent, 2))
print(conf_matrix)

# Calculate precision, recall, and accuracy and print them
precision <- sum(predicted_classes == actual_classes & actual_classes == 1) / sum(predicted_classes == 1)
recall <- sum(predicted_classes == actual_classes & actual_classes == 1) / sum(actual_classes == 1)
accuracy <- sum(predicted_classes == actual_classes) / length(actual_classes)

print(paste("Precision:", precision))
print(paste("Recall:", recall))
print(paste("Accuracy:", accuracy))

# Fit a quasi-Poisson regression model to predict the number of rooms (Nr_rooms)
modelo_quasi_poisson <- glm(Nr_rooms ~ Price_Gross + Size_m2, family = quasipoisson, data = train_set)

# Display the summary of the quasi-Poisson model
summary(modelo_quasi_poisson)

# Predict values for the test set and calculate mean squared error (MSE)
predicted_values_test_quasi <- predict(modelo_quasi_poisson, newdata = test_set, type = "response")
test_set$fitted_values_quasi <- predicted_values_test_quasi

mse_test_quasi <- mean((test_set$Nr_rooms - test_set$fitted_values_quasi)^2)
print(paste("Testing Set Mean Squared Error for Nr_rooms (Quasi-Poisson):", mse_test_quasi))

# Calculate and print root mean squared error (RMSE)
rmse_test_quasi <- sqrt(mse_test_quasi)
print(paste("Testing Set Root Mean Squared Error for Nr_rooms (Quasi-Poisson):", rmse_test_quasi))

# Plot actual vs. predicted values for the quasi-Poisson model
plot(test_set$Nr_rooms, test_set$fitted_values_quasi, 
     main = "Actual vs Predicted Values for Nr_rooms (Quasi-Poisson)", 
     xlab = "Actual Nr_rooms", 
     ylab = "Predicted Nr_rooms")
abline(0, 1, col = "red")

--------------------------------------------------------------------------------
# Poisson
--------------------------------------------------------------------------------
# Apply logarithmic transformation to the predictor variables
train_set$log_Price_Gross <- log(train_set$Price_Gross + 1)
train_set$log_Size_m2 <- log(train_set$Size_m2 + 1)
test_set$log_Price_Gross <- log(test_set$Price_Gross + 1)
test_set$log_Size_m2 <- log(test_set$Size_m2 + 1)

# Fit a quasi-Poisson model with log-transformed variables
quasipoisson.model <- glm(Nr_rooms ~ log_Price_Gross + log_Size_m2 + Category_num + Canton_num, 
                          family = quasipoisson, data = train_set)

# Display the summary of the log-transformed quasi-Poisson model
summary(quasipoisson.model)

# Predict values for the test set using the log-transformed quasi-Poisson model
predicted_values_test_quasi_log <- predict(quasipoisson.model, newdata = test_set, type = "response")
test_set$fitted_values_quasi_log <- predicted_values_test_quasi_log

# Plot actual vs. predicted values for the log-transformed quasi-Poisson model
plot(test_set$Nr_rooms, test_set$fitted_values_quasi_log, 
     main = "Actual vs Predicted Values for Nr_rooms (Log Transformed Quasi-Poisson)", 
     xlab = "Actual Nr_rooms", 
     ylab = "Predicted Nr_rooms")
abline(0, 1, col = "red")

