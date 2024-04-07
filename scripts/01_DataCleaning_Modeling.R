# Data Cleaning for Model Training
# Target Variable: Price_Gross

library(readxl)
data_total <- read_excel("data/data_cleaned/data_total.xlsx")

str(data_total)

summary(data_total)
# NA count: 
sum(!complete.cases(data_total)) # 2098
head(rowSums(is.na(data_total))) # 3 2 2 2 2 2
colSums(is.na(data_total))#
# Price_Gross: 44
# Size_m2:318
# Official_language_2: 1926
# Official_language_3: 2096

# Remove language columns as they are irrelevant to price
columns_to_drop <- c("Official_Language_1","Official_Language_2",
                     "Official_Language_3")
data <- data_total[, !names(data_total) %in% columns_to_drop]

# Remove rows with NA in Price_Gross column
data <- data[!is.na(data$Price_Gross),]
colSums(is.na(data))

sum(is.na(data$Size_m2))/length(data$Size_m2) # 14.07% of values are missing



