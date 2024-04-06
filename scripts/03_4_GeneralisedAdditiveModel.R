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

--------------------------------------------------------------------------------
  
# Load data sets
df_total <- read_excel("C:/Users/Victor/Desktop/ML1/data/data_cleaned/data_total.xlsx")

head(df_total)
colnames(df_total)

--------------------------------------------------------------------------------
  
# Assuming df_total is your data frame and it's already loaded
  
  # Convert dates to numerical format (e.g., days since a reference date)
df_total$FirstDay_Online <- as.numeric(as.Date(df_total$FirstDay_Online) - as.Date('2000-01-01'))
df_total$LastDay_Online <- as.numeric(as.Date(df_total$LastDay_Online) - as.Date('2000-01-01'))

# Handle categorical variables
df_total <- df_total %>%
  mutate_at(vars(Canton, Customer_Segment, Package_Product), as.factor) %>%
  mutate_at(vars(Canton, Customer_Segment, Package_Product), as.integer)  # Convert factors to integer codes

# Split the data into training and testing sets
set.seed(123)  # for reproducibility
training_indices <- sample(1:nrow(df_total), size = 0.8 * nrow(df_total))

train_data <- df_total[training_indices, ]
test_data <- df_total[-training_indices, ]

# 2. Model Training

# You’ll then train different models using the predictors to estimate the "Price_Gross". Each model has its own function in R:

#   Linear Model
lm_model <- lm(Price_Gross ~ ., data = train_data)
# Generalized Linear Model with Poisson family
glm_poisson <- glm(Price_Gross ~ ., family = "poisson", data = train_data)

# Generalized Linear Model with Binomial family
# This is typically used for binary outcomes, so it may not be appropriate unless your 'Price_Gross' is binary.
glm_binomial <- glm(Price_Gross ~ ., family = "binomial", data = train_data)

# Generalized Additive Model
library(mgcv)
gam_model <- gam(Price_Gross ~ s(Size_m2) + s(Nr_rooms) + ..., data = train_data)

# Neural Network
library(neuralnet)
nn_model <- neuralnet(Price_Gross ~ ., data = train_data)

# Support Vector Machine
library(e1071)
svm_model <- svm(Price_Gross ~ ., data = train_data)

# 3. Model Validation
# After training, you should validate your models on the test dataset to see how well they perform.

# # Example for the linear model
predictions <- predict(lm_model, newdata = test_data)
cor(test_data$Price_Gross, predictions)  # Check for correlation between predictions and actual prices



  