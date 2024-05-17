# Required Packages
library(readxl)
library(neuralnet)

# Reading in data
enc_data <- read_excel("data/data_cleaned/data_total_model.xlsx")
enc_data <- enc_data[, !(names(enc_data) %in% "X"), drop = TRUE]

# Feature Engineering
enc_data$Price_per_m2 <- enc_data$Price_Gross / enc_data$Size_m2
q3 <- median(enc_data$Price_per_m2) + IQR(enc_data$Price_per_m2) / 2
enc_data$High_Ticket <- enc_data$Price_per_m2 > q3
enc_data$High_Ticket <- ifelse(enc_data$High_Ticket, 1, 0)

# Declaring Categorical Variables
enc_data$Canton_num <- as.numeric(as.factor(enc_data$Canton_num))
enc_data$Customer_Segment_num <- as.numeric(as.factor(enc_data$Customer_Segment_num))
enc_data$Category_num <- as.numeric(as.factor(enc_data$Category_num))
enc_data$Nr_rooms <- as.numeric(enc_data$Nr_rooms) # Treating Nr_rooms as continuous
enc_data$Package_Product_num <- as.numeric(as.factor(enc_data$Package_Product_num))

# Normalizing the data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

features <- subset(enc_data, select = -High_Ticket)
maxmindf_features <- as.data.frame(lapply(features, normalize))

High_Ticket <- enc_data$High_Ticket
maxmindf <- cbind(High_Ticket, maxmindf_features)

# Split into train and test sets
set.seed(36)
smpl <- sample.int(n = nrow(maxmindf), size = floor(0.8 * nrow(maxmindf)), replace = FALSE)
train_maxmin <- maxmindf[smpl, ]
test_maxmin <- maxmindf[-smpl, ]

# Modeling
model_maxmin <- neuralnet(High_Ticket ~ ., data = train_maxmin, hidden = c(3, 8, 5), linear.output = FALSE)

# Predicting
pred_maxmin <- predict(model_maxmin, test_maxmin)

# Testing the Accuracy of the models
maxmin_results <- data.frame(actual = test_maxmin$High_Ticket, prediction = pred_maxmin)

# Confusion matrix
roundedresults <- sapply(maxmin_results, round, digits = 0)
roundedresultsdf <- data.frame(roundedresults)

nn_conf <- confusionMatrix(as.factor(roundedresultsdf$prediction),
                           as.factor(roundedresultsdf$actual),
                           dnn=c("Prediction", "Reference"))

# Plotting the model
plot(model_maxmin)
