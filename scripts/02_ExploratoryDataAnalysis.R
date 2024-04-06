--------------------------------------------------------------------------------
  
# Exploratory Data Analysis

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
df_total <- read_excel("C:/Users/Victor/Desktop/ML1/data/data_cleaned/data_total.xlsx")

head(df_total)
colnames(df_total)

# - What is the distribution of rental prices in different cantons?
# - Is there a correlation between the size of the property (in m2) and the rental price?
# - How does the number of rooms affect the rental price?
# - What is the trend in rental prices over time (based on FirstDay_Online)?
# - Are there differences in rental prices between different customer segments?
# - How does the GDP per capita of a canton relate to the average rental price in that canton?
# - Is there a correlation between the population density of a canton and rental prices?
# - What are the most common types of properties listed for rent?
# - How do rental prices vary between flats and houses?
# - Are there differences in the length of time properties remain online between different cantons or property categories?
  
--------------------------------------------------------------------------------
  
# Histogram for Price_Gross
ggplot(df_total, aes(x = Price_Gross)) +
  geom_histogram(bins = 30, fill = "darkblue", color = "black") +
  labs(title = "Distribution of Rental Prices", x = "Gross Price (CHF)", y = "Frequency") +
  theme_minimal()

--------------------------------------------------------------------------------
# SIZE
  
# Histogram for Size_m2
ggplot(df_total, aes(x = Size_m2)) +
  geom_histogram(bins = 30, fill = "darkblue", color = "black") +
  labs(title = "Distribution of Property Size", x = "Size (m²)", y = "Frequency") +
  theme_minimal()

ggplot(df_total, aes(x = Size_m2, y = Price_Gross)) +
  geom_point(aes(color = Category)) + # Color code by property category
  labs(title = "Price vs. Size of Property", x = "Size (m²)", y = "Gross Price (CHF)") +
  theme_minimal()

--------------------------------------------------------------------------------
  
# Histogram for Nr_rooms
ggplot(df_total, aes(x = Nr_rooms)) +
  geom_histogram(bins = 30, fill = "darkblue", color = "black") +
  labs(title = "Distribution of Number of Rooms", x = "Number of Rooms", y = "Frequency") +
  theme_minimal()

