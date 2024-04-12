--------------------------------------------------------------------------------
  
# Generalised Additive Model
  
--------------------------------------------------------------------------------

# Install libraries

library(readr)
library(ggplot2)
library(stringr)
library(dplyr)
library(readxl)
library(openxlsx)
library(lubridate)
library(mgcv)
library(splines)

--------------------------------------------------------------------------------

# Set seed for reproducibility
set.seed(71)

# Reading in data
enc_data <- read_excel("data/data_cleaned/data_total_model.xlsx")

# Splitting the data into training and testing
split_ratio <- 0.8
training_indices <- sample(1:nrow(enc_data), 
                           size = nrow(enc_data) * split_ratio,
                           replace = FALSE)

train_set <- enc_data[training_indices, ]
test_set <- enc_data[-training_indices, ]

# Convert character variables to numeric
train_set$Nr_rooms <- as.numeric(train_set$Nr_rooms)
train_set$Canton_num <- as.numeric(train_set$Canton_num)
train_set$Customer_Segment_num <- as.numeric(train_set$Customer_Segment_num)
train_set$Category_num <- as.numeric(train_set$Category_num)
train_set$Package_Product_num <- as.numeric(train_set$Package_Product_num)

# Apply the same conversion to the test set
test_set$Nr_rooms <- as.numeric(test_set$Nr_rooms)
test_set$Canton_num <- as.numeric(test_set$Canton_num)
test_set$Customer_Segment_num <- as.numeric(test_set$Customer_Segment_num)
test_set$Category_num <- as.numeric(test_set$Category_num)
test_set$Package_Product_num <- as.numeric(test_set$Package_Product_num)

# Fit the GAM model
#gam_model <- gam(Price_Gross ~ s(Nr_rooms) + s(Category_num), data = train_set)

# Fit the GAM model with reduced degrees of freedom
gam_model <- gam(Price_Gross ~ bs(Nr_rooms, df = 5) + bs(Category_num, df = 3), data = train_set)

# Summary of the GAM model
summary(gam_model)

# Model Predictions
gam_predictions <- predict(gam_model, newdata = test_set)

# Model Evaluation
gam_rmse <- sqrt(mean((gam_predictions - test_set$Price_Gross)^2))
gam_mae <- mean(abs(gam_predictions - test_set$Price_Gross))
cat("MAE:", gam_mae, "\n")
cat("RMSE:", gam_rmse, "\n")

# Plotting
plot(gam_model)





  