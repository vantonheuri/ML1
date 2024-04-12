# Data Cleaning for Model Training
# Target Variable: Price_Gross

library(readxl)
library(dplyr)
library(naniar)
library(ggplot2)
library(heatmaply)
library(caret)

data_total <- read_excel("data/data_cleaned/data_total.xlsx")

# As agreed upon for analysis:
# Limited to these cantons
cantons <- c("AG", "LU", "ZH", "ZU")
# Limited to these property categories
categories <- c("Appartment", "House")

length(data_total$Canton)

data_total <- data_total %>%
  filter(Category %in% categories)
data_total <- data_total %>%
  filter(Canton %in% cantons)

str(data_total)
summary(data_total)

# NA count: 
sum(!complete.cases(data_total)) # 1023
head(rowSums(is.na(data_total))) # 3 2 2 2 2 2
colSums(is.na(data_total))
# Price_Gross: 8
# Size_m2:105
# Official_language_2: 1023
# Official_language_3: 1023
length(unique(data_total$Official_Language_1))
# Remove language and ID columns as they are irrelevant to price
columns_to_drop <- c("Official_Language_1","Official_Language_2",
                     "Official_Language_3","Property_ID",
                     "Customer_ID", "Package_ID",
                     "Canton_Name", "Canton_Capital")
data <- data_total[, !names(data_total) %in% columns_to_drop]

# Rearrange data to have target variable at far right column
data <- data %>%
  select(all_of(names(data)[- which(names(data) == "Size_m2")]),
         "Size_m2")

# Remove rows with NA in Price_Gross column (8)
data <- data[!is.na(data$Price_Gross),]

sum(is.na(data$Size_m2))/length(data$Size_m2) # 10.15 of values are missing

# Still missing values in Size_m2
colSums(is.na(data))
summary(is.na(data))
summary(data)

# Drop rows with NA values in Size_m2
data <- data[!is.na(data$Size_m2),]

# Create a column for Difference in Time
data$Days_Difference <- difftime(data$LastDay_Online, data$FirstDay_Online, units = "days")

# Encoding Categorical Data
encoded_data <- transform(data,
                     Canton_num=as.numeric(
                       factor(Canton,
                              levels=unique(data$Canton))
                     ),
                     Type_num=as.numeric(
                       factor(Type,
                              levels=unique(data$Type))
                     ),
                     Customer_Segment_num=as.numeric(
                       factor(Customer_Segment,
                              levels=unique(data$Customer_Segment))
                     ),
                     Category_num=as.numeric(
                       factor(Category,
                              levels=unique(data$Category))
                     ),
                     Package_Product_num=as.numeric(
                       factor(Package_Product,
                              levels=unique(data$Package_Product))
                     )
)

encoded_order <- c("Canton_num", "Days_Difference", "Type_num",
                   "Customer_Segment_num", "Category_num", "Nr_rooms",
                   "Package_Product_num", "GDP_2020_21", "GDP_per", "Population",
                   "Area_km2", "Density", "Size_m2",
                   "Price_Gross")
final_data <- encoded_data %>%
  select(encoded_order)  # Specify the desired order
str(final_data)

# Save file to local repo
write.csv(final_data, "data/data_cleaned/data_total_model.csv")
