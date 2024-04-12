# SVM
# Target Variable: Price_Gross
#-------------------------------------------------------------------------------
# Required Packages
library(readxl)
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
