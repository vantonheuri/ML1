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
library(ROSE)  # ROSE package for oversampling techniques

--------------------------------------------------------------------------------
# Binomial 
  # Leer y preparar datos
enc_data <- read_excel("data/data_cleaned/data_total_model.xlsx") %>%
  mutate(fast.sale = ifelse(Days_Difference <= 17, 1, 0))

mean(enc_data$Days_Difference)

# Dividir datos en entrenamiento y prueba
set.seed(71)
split_ratio <- 0.8
training_indices <- sample(1:nrow(enc_data), size = nrow(enc_data) * split_ratio, replace = FALSE)

train_set <- enc_data[training_indices, ]
test_set <- enc_data[-training_indices, ]

--------------------------------------------------------------------------------
# Ajustar el Modelo Binomial
binomial.model <- glm(fast.sale ~ Price_Gross + Nr_rooms + Size_m2 + Canton_num + Customer_Segment_num + Category_num, 
                           family = binomial, data = train_set)

# Ver los resultados del modelo
summary(binomial.model)
----------------------
coef <- coef(modelo_glm_binomial)
odds_ratios <- exp(coef)
print(odds_ratios)
----------------------

# Calcular los valores ajustados (fitted values) para el conjunto de entrenamiento
fitted_values_train <- fitted(binomial.model)
train_set$fitted_values <- fitted_values_train
head(train_set[, c("fast.sale", "fitted_values")])

# Predicciones en el conjunto de prueba
predicted_probabilities_test <- predict(binomial.model, test_set, type = "response")
test_set$fitted_values <- predicted_probabilities_test
head(test_set[, c("fast.sale", "fitted_values")])

# Calcular y mostrar la matriz de confusión
predicted_classes <- ifelse(predicted_probabilities_test > 0.5, 1, 0)
actual_classes <- test_set$fast.sale
conf_matrix <- table(Predicted = predicted_classes, Actual = actual_classes)
conf_matrix_percent <- prop.table(conf_matrix) * 100
print(round(conf_matrix_percent, 2))
print(conf_matrix)

# Cálculo de métricas
precision <- sum(predicted_classes == actual_classes & actual_classes == 1) / sum(predicted_classes == 1)
recall <- sum(predicted_classes == actual_classes & actual_classes == 1) / sum(actual_classes == 1)
accuracy <- sum(predicted_classes == actual_classes) / length(actual_classes)

print(paste("Precision:", precision))
print(paste("Recall:", recall))
print(paste("Accuracy:", accuracy))

--------------------------------------------------------------------------------
# Poisson
  
modelo_poisson_completo <- glm(Days_Difference ~ ., 
                                 family = poisson, data = train_set)

summary(modelo_poisson_completo)

# Calculate fitted values for the training set
fitted_values_train <- predict(modelo_poisson_completo, type = "response")
train_set$fitted_values <- fitted_values_train

# Display the first few rows of actual vs fitted values for training set
head(train_set[, c("Days_Difference", "fitted_values")])

str(train_set)


vif_values <- vif(modelo_poisson_completo)
print(vif_values)

