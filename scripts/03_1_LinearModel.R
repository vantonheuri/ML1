# Linear Model
# Target Variable: Price_Gross
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PENDING
# Nr_rooms must not be categorical, but continuous
#-------------------------------------------------------------------------------
# Required Packages
library(readxl)
library(ggplot2)
#-------------------------------------------------------------------------------
set.seed(71)
# Reading in data
enc_data <- read_excel("data/data_cleaned/data_total_model.xlsx")
#enc_data <- enc_data[, !(names(enc_data) %in% "X"), drop = TRUE]

# Declaring Categorical Variables
#enc_data$Canton_num <- factor(enc_data$Canton_num)
#enc_data$Customer_Segment_num <- factor(enc_data$Customer_Segment_num)
#enc_data$Category_num <- factor(enc_data$Category_num)
#enc_data$Nr_rooms <- factor(enc_data$Nr_rooms)
#enc_data$Package_Product_num <- factor(enc_data$Package_Product_num)

#Splitting the data into training and testing
split_ratio <- 0.8
training_indices <- sample(1:nrow(enc_data), 
                           size=nrow(enc_data) * split_ratio,
                           replace=FALSE)

train_set <- enc_data[training_indices,]
test_set <- enc_data[-training_indices,]

#Fit the model    data[, !(names(data) %in% column_to_exclude)]
all_lm_model <- lm(Price_Gross ~ ., data=train_set)

# Retraining with only relevant variables
rel_data <- enc_data[, !(names(enc_data) %in% 
                           c("Package_Product_num",
                             "Type_num",
                             "GDP_2020_21","GDP_per",
                             "Population",
                              "Area_km2", "Density")), drop = TRUE]

rel_train_set <- rel_data[training_indices,]
rel_test_set <- rel_data[-training_indices,]

# Fit the model
few_lm_model <- lm(Price_Gross ~ ., data=rel_train_set)

# Retraining with fewer variables
simp_data <- enc_data[, c("Nr_rooms", "Category_num", "Price_Gross")]

simp_train_set <- simp_data[training_indices,]
simp_test_set <- simp_data[-training_indices,]

# Fit the model
simple_lm_model <- lm(Price_Gross ~ ., data=simp_train_set)



summary(all_lm_model)
summary(few_lm_model) #Similar performance on less variables, prevents overfitting
summary(simple_lm_model) # Lower multiple R-squared and Adjusted R-Squared
#Model Predictions
all_lm_predictions <- predict(all_lm_model, newdata=test_set)
few_lm_predictions <- predict(few_lm_model, 
                              newdata=rel_test_set)
simple_lm_predictions <- predict(simple_lm_model, 
                                 newdata=simp_test_set)

#Model Evaluation
#Add lines of best fit with ggplot2
par(mfrow=c(3,1))
plot(test_set$Price_Gross, all_lm_predictions, main="Target Vs. lm_predictions")
plot(rel_test_set$Price_Gross, few_lm_predictions,
     main="Target Vs. new_lm_predictions")
plot(simp_test_set$Price_Gross, simple_lm_predictions,
     main="Target Vs. simple_lm_predictions")

par(mfrow=c(3,1))
scatter.smooth(all_lm_predictions, main="lm_predictions")
scatter.smooth(few_lm_predictions, main="new_lm_predictions")
scatter.smooth(simple_lm_predictions, main="simple_lm_predictions")


rmse <- sqrt(mean((all_lm_predictions - test_set$Price_Gross)^2))
mae <- mean(abs(all_lm_predictions - test_set$Price_Gross))
mae
rmse

new_rmse <- sqrt(mean((few_lm_predictions - rel_test_set$Price_Gross)^2))
new_mae <- mean(abs(few_lm_predictions - rel_test_set$Price_Gross))
new_mae
new_rmse

simp_rmse <- sqrt(mean((simple_lm_predictions - simp_test_set$Price_Gross)^2))
simp_mae <- mean(abs(simple_lm_predictions - simp_test_set$Price_Gross))
simp_mae
simp_rmse
