--------------------------------------------------------------------------------
  
# Data Cleaning

--------------------------------------------------------------------------------
# Install libraries
library(readr)
library(ggplot2)
library(stringr)

--------------------------------------------------------------------------------

# Load data sets
df_kanton <- read_csv("C:/Users/Victor/Desktop/ML1/data/data_kantons.csv")
df_homegate <- read_csv("C:/Users/Victor/Desktop/ML1/data/dataset_homegate.csv")

head(df_kanton)
head(df_homegate)

colnames(df_kanton)
colnames(df_homegate)

# Dividir la columna en df_kanton utilizando el delimitador ;
df_kanton <- str_split_fixed(df_kanton, ";", n = 12)


# Left Join
merged_df <- merge(df_homegate, df_kanton, by.x = "Code", by.y = "GEO_KANTON", all.x = TRUE)

