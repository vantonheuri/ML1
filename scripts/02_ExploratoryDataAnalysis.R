--------------------------------------------------------------------------------
  
# Exploratory Data Analysis

--------------------------------------------------------------------------------
# Install libraries

library(readr)
library(ggplot2)
library(stringr)
library(dplyr)
library(readxl)

--------------------------------------------------------------------------------
  
# Load data sets
df_kanton <- read_excel("C:/Users/Victor/Desktop/ML1/data/data_raw/data_kantons.xlsx")
df_homegate <- read_excel("C:/Users/Victor/Desktop/ML1/data/data_raw/dataset_homegate.xlsx")

head(df_kanton)
head(df_homegate)