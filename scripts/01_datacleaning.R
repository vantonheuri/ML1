--------------------------------------------------------------------------------
  
# Data Cleaning

--------------------------------------------------------------------------------
# Install libraries
  
library(readr)
library(ggplot2)
library(stringr)
library(dplyr)
library(readxl)
library(openxlsx)

--------------------------------------------------------------------------------

# Load data sets
df_kanton <- read_excel("C:/Users/Victor/Desktop/ML1/data/data_raw/data_kantons.xlsx")
df_homegate <- read_excel("C:/Users/Victor/Desktop/ML1/data/data_raw/dataset_homegate.xlsx")

head(df_kanton)
head(df_homegate)

colnames(df_kanton)
colnames(df_homegate)

# Left Join
df_total <- merge(df_homegate,df_kanton, by = "Canton")

head(df_total)
colnames(df_total)
dim(df_total)

# > dim(df_total)
# [1] 3417   23


# Now we focus only on analysing the properties to be rented and whether they are houses or appartments
df_total <- df_total[df_total$Type == "Rent" & (df_total$Category == "House" | df_total$Category == "Appartment"), ]

dim(df_total)
# > dim(df_total)
# [1] 2141   23

--------------------------------------------------------------------------------
  
#Export file to a xlsx 
path <- "C:/Users/Victor/Desktop/ML1/data/data_cleaned/"
file_name <- "data_total.xlsx"

# Combine path and file name
full_path <- paste0(path, file_name)

# Export DataFrame to Excel file
write.xlsx(df_total, full_path, row.names = FALSE)

# Confirmation message
cat("File exported successfully to:", full_path)
