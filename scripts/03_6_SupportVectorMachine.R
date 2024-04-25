# SVM
# Target Variable: Price_Gross
# SVMs are good for high-dimensional data, so we can one-hot encode data
# SVM performance vs NeuralNet for High Ticket classification
#-------------------------------------------------------------------------------
# Required Packages
library(readxl)
library(caret)
#-------------------------------------------------------------------------------

# Reading in data
enc_data <- read_excel("data/data_cleaned/data_total_model.xlsx")
enc_data <- enc_data[, !(names(enc_data) %in% "X"), drop = TRUE]

#Feature Engineering
enc_data$Price_per_m2 <- enc_data$Price_Gross / enc_data$Size_m2
q3 <- median(enc_data$Price_per_m2) + IQR(enc_data$Price_per_m2) / 2
enc_data$High_Ticket <- enc_data$Price_per_m2 > q3
enc_data$High_Ticket <- ifelse(enc_data$High_Ticket, 1, 0)

str(enc_data)

