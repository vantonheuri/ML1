# Linear Model
# Target Variable: Price_Gross
#-------------------------------------------------------------------------------
# Required Packages

#-------------------------------------------------------------------------------

# Reading in data
enc_data <- read.csv("data/data_cleaned/data_total_model.csv")
enc_data <- enc_data[, !(names(enc_data) %in% "X"), drop = TRUE]

str(enc_data)
#Splitting the data into training and testing
split_ratio <- 0.8
training_indices <- sample(1:nrow(enc_data), 
                           size=nrow(enc_data) * split_ratio,
                           replace=FALSE)

train_set <- enc_data[training_indices,]
test_set <- enc_data[-training_indices,]

lm_model <- lm(Price_Gross ~ ., data=train_set[-train_set$Price_Gross])

#Evaluation
summary(lm_model)
summary(lm_model)$r.squared
summary(lm_model)$adj.r.squared
summary(lm_model)$accuracy

# Retraining with only relevant variables
rel_data <- enc_data[, !(names(enc_data) %in% 
                           c("Package_Product_num",
                             "Type_num",
                             "GDP_2020_21","GDP_per",
                             "Population",
                              "Area_km2", "Density")), drop = TRUE]
training_indices <- sample(1:nrow(rel_data), 
                           size=nrow(rel_data) * split_ratio,
                           replace=FALSE)

rel_train_set <- rel_data[training_indices,]
rel_test_set <- rel_data[-training_indices,]

new_lm_model <- lm(Price_Gross ~ ., data=rel_train_set[-rel_train_set$Price_Gross])

summary(lm_model)
summary(new_lm_model) #Similar performance on less variables, prevent overfitting

#Model Predictions
lm_predictions <- predict(lm_model, newdata=test_set[-test_set$Price_Gross])
new_lm_predictions <- predict(new_lm_model, 
                              newdata=rel_test_set[-rel_test_set$Price_Gross])

#Model Evaluation

par(mfrow=c(2,2))
plot(lm_model)
plot(new_lm_model)

par(mfrow=c(1,2))
plot(test_set$Price_Gross, lm_predictions, main="Target Vs. lm_predictions")
plot(rel_test_set$Price_Gross, new_lm_predictions,
     main="Target Vs. new_lm_predictions")

par(mfrow=c(1,1))
scatter.smooth(new_lm_predictions)


rmse <- sqrt(mean((lm_predictions - test_set$Price_Gross)^2))
mae <- mean(abs(lm_predictions - test_set$Price_Gross))
mae
rmse

new_rmse <- sqrt(mean((new_lm_predictions - test_set$Price_Gross)^2))
new_mae <- mean(abs(new_lm_predictions - rel_test_set$Price_Gross))
new_mae
new_rmse


