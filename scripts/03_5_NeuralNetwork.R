# NN
# Classification Variable: High_Ticket
# - highest quartile of (Price_Gross / Size_m2) threshold ><
#-------------------------------------------------------------------------------
# Required Packages
library(readxl)
library(neuralnet)
#-------------------------------------------------------------------------------

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

enc_data <- enc_data %>% mutate_if(is.character, as.factor) # Converting to factor w/
enc_data$High_Ticket <- factor(enc_data$High_Ticket)

#  2 levels
#Splitting the data into training and testing
set.seed(245)

data_rows <- floor(0.8 * nrow(enc_data))
train_indices <- sample(c(1:nrow(enc_data)), data_rows)
train_data <- enc_data[train_indices,]
test_data <- enc_data[-train_indices,]

################################################################################
# Modeling
