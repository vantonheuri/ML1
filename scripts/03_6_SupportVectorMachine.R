# SVM
# Target Variable: Price_Gross
# SVMs are good for high-dimensional data, so we can one-hot encode data
# SVM performance vs NeuralNet for High Ticket classification
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PENDING
# Nr_rooms must not be categorical, but continuous
#-------------------------------------------------------------------------------
# Required Packages
library(readxl)
library(caret)
library(e1071)
#-------------------------------------------------------------------------------

# Reading in data
ohe_data <- read_excel("data/data_cleaned/data_total_model_one_hot_encoded.xlsx")

#Feature Engineering
ohe_data$Price_per_m2 <- ohe_data$Price_Gross / ohe_data$Size_m2
q3 <- median(ohe_data$Price_per_m2) + IQR(ohe_data$Price_per_m2) / 2
ohe_data$High_Ticket <- ohe_data$Price_per_m2 > q3
ohe_data$High_Ticket <- ifelse(ohe_data$High_Ticket, 1, 0)

# Price_per_m2 causes collinearity issues
# Nr_rooms.8 has only one positive value, so we remove the row
# Nr_rooms.10 is constant, so we remove it as well
ohe_data <- ohe_data[, !names(ohe_data) %in% c("Price_per_m2","Nr_rooms.8",
                                               "Nr_rooms.10")]

# Convert target to factor since this is a classification problem (binary)
ohe_data$High_Ticket <- as.factor(ohe_data$High_Ticket)

# Random seed for reproducibility
set.seed(123)

# Split the data into training and test sets
train_index <- sample(seq_len(nrow(ohe_data)), size = floor(0.8 * nrow(ohe_data)))
train_data <- ohe_data[train_index, ]
test_data <- ohe_data[-train_index, ]

# Set up train control for cross-validation
train_control <- trainControl(
  method = "cv",         # Cross-validation
  number = 10,           # Number of folds
  savePredictions = "final",
  classProbs = TRUE,     # If you want class probabilities
  summaryFunction = twoClassSummary
)


# Train the SVM model
svm_model <- svm(High_Ticket ~ ., data = train_data,trControl=train_contor,
                 kernel = "radial",
                 cost = 10, scale = TRUE)

# Exclude the target variable from the test set
test_data_without_target <- test_data[, !names(test_data) %in% 'High_Ticket']

# Make predictions
predictions <- predict(svm_model, newdata = test_data_without_target)

# Evaluate the model (assuming classification, adjust if it's regression)
confusionMatrix(predictions, test_data$High_Ticket)

# Calculate confusion matrix
confusion <- confusionMatrix(as.factor(predictions), as.factor(test_data$High_Ticket))

