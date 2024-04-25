# SVM
# Target Variable: Price_Gross
# SVMs are good for high-dimensional data, so we can one-hot encode data
# SVM performance vs NeuralNet for High Ticket classification
#-------------------------------------------------------------------------------
# Required Packages
library(readxl)
library(caret)
library(e1071)
#-------------------------------------------------------------------------------

# Reading in data
ohe_data <- read_excel("data/data_cleaned/data_total_model_one_hot_encoded.xlsx")
ohe_data <- enc_data[, !(names(enc_data) %in% "X"), drop = TRUE]

#Feature Engineering
ohe_data$Price_per_m2 <- ohe_data$Price_Gross / ohe_data$Size_m2
q3 <- median(ohe_data$Price_per_m2) + IQR(ohe_data$Price_per_m2) / 2
ohe_data$High_Ticket <- ohe_data$Price_per_m2 > q3
ohe_data$High_Ticket <- ifelse(ohe_data$High_Ticket, 1, 0)

# Nr_rooms.8 has only one positive value, so we remove the column
ohe_data <- ohe_data[, !names(ohe_data) %in% c("Price_per_m2","Nr_rooms.8")]

# Random seed for reproducibility
set.seed(32)

# Split data into training and test sets
split_index <- createDataPartition(ohe_data$High_Ticket, times = 5, p=.8)
train_index <- split_index[[1]]
test_index <- split_index[[2]]

train_set <- ohe_data[train_index,]
test_set <- ohe_data[test_index,]

# Modelling
svm_formula <- High_Ticket ~ .
svm_model <- svm(svm_formula, data=train_set, kernel="linear", cost=1)


# Predictions
preds <- predict(svm_model, newdata = test_set[-test_set$High_Ticket])
cm <- confusionMatrix(preds, test_set$High_Ticket)
print(cm)
