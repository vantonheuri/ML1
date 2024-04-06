--------------------------------------------------------------------------------
  
# Generalised Additive Model
  
--------------------------------------------------------------------------------

# Install libraries

library(readr)
library(ggplot2)
library(stringr)
library(dplyr)
library(readxl)
library(openxlsx)
library(lubridate)

--------------------------------------------------------------------------------
  
# Load data sets
df_total <- read_excel("C:/Users/Victor/Desktop/ML1/data/data_cleaned/data_total.xlsx")

head(df_total)
colnames(df_total)

--------------------------------------------------------------------------------