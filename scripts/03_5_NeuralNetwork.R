# NN
# Classification Variable: High_Ticket
# - highest quartile of (Price_Gross / Size_m2) threshold ><
#-------------------------------------------------------------------------------
# Required Packages
library(readxl)
library(tensorflow)
library(keras)
#-------------------------------------------------------------------------------
set.seed(71)
# Reading in data
enc_data <- read_excel("data/data_cleaned/data_total_model.xlsx")
enc_data <- enc_data[, !(names(enc_data) %in% "X"), drop = TRUE]

# Declaring Categorical Variables
enc_data$Canton_num <- factor(enc_data$Canton_num)
enc_data$Customer_Segment_num <- factor(enc_data$Customer_Segment_num)
enc_data$Category_num <- factor(enc_data$Category_num)
enc_data$Nr_rooms <- factor(enc_data$Nr_rooms)
enc_data$Package_Product_num <- factor(enc_data$Package_Product_num)

#Feature Engineering
enc_data$Price_per_m2 <- enc_data$Price_Gross / enc_data$Size_m2
q3 <- median(enc_data$Price_per_m2) + IQR(enc_data$Price_per_m2) / 2
enc_data$High_Ticket <- enc_data$Price_per_m2 > q3
enc_data$High_Ticket <- ifelse(enc_data$High_Ticket, 1, 0)

#Splitting the data into training and testing












################################################################################
#Testing


# Sample data (replace with your actual data)
set.seed(123)  # For reproducibility
data <- data.frame(
  x1 = rnorm(100),
  x2 = rnorm(100),
  target = sample(c(0, 1), 100, replace = TRUE)  # Binary target variable (0 or 1)
)

# Split data into training and testing sets (replace with your actual split ratio)
train_split <- 0.8
train_set <- data[sample(nrow(data), floor(nrow(data) * train_split)), ]
test_set <- data[-c(which(rownames(data) %in% rownames(train_set))), ]

# Define the neural network model
model <- neuralnet(formula = target ~ x1 + x2,
                   data = train_set,
                   hidden = c(5),  # One hidden layer with 5 neurons (adjustable)
                   linear.output = FALSE,  # Non-linear activation in the output layer
                   act.fct = "logistic")  # Logistic activation for binary classification

# Train the model
set.seed(123)  # For reproducibility
model <- train(model, method = "bfgs")  # Train using Broyden-Fletcher-Goldfarb-Shanno (BFGS) algorithm

# Make predictions on the test set
predictions <- compute(model, test_set)

# Evaluate the model (replace with appropriate metrics)
# You can use confusion matrix, accuracy, precision, recall, F1-score etc.
confusion_matrix <- table(test_set$target, predictions)
print(confusion_matrix)

# Optional: Get predicted class labels (0 or 1) instead of probabilities
predicted_class <- ifelse(predictions > 0.5, 1, 0)
# 'predicted_class' now contains the predicted class labels (0 or 1)

