# Data Cleaning for Model Training
# Target Variable: Price_Gross

library(readxl)
library(dplyr)
library(naniar)
library(ggplot2)
library(heatmaply)

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

# Analyze missing data
missing_prop <- colMeans(is.na(data))
ggplot(data.frame(variable=names(data), missing_prop=missing_prop))+
  aes(x=variable, y=missing_prop) +
  geom_col(aes(fill=missing_prop), stat="identity") + #color based on missingness proportion
  labs(title="Missing Value Heatmap", x="Variable", y="Proportion Missing") +
  scale_fill_gradient(low="white", high="red")
heatmaply_na(data[1:30,],
             showtickables=c(TRUE,FALSE))
length(data)