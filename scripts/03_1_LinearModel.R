# Linear Model
# Target Variable: Price_Gross

# Required Packages

# Reading in data
enc_data <- read.csv("data/data_cleaned/data_total_model.csv")

#Splitting the data into training and testing
split_ratio <- 0.8
training_indices <- sample(1:nrow(enc_data), 
                           size=nrow(enc_data) * split_ratio,
                           replace=FALSE)

train_set <- enc_data[training_indices,]
test_set <- enc_data[-training_indices,]

lm_model <- lm(Price_Gross ~ ., data=train_set[-train_set$Price_Gross])

#Model Predictions
lm_predictions <- predict(lm_model, newdata=test_set[-test_set$Price_Gross])
summary(lm_predictions)
#Evaluation
