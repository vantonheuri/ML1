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
library(lubridate)



--------------------------------------------------------------------------------
  
# Load data sets
df_total <- read_excel("data/data_cleaned/data_total.xlsx")

head(df_total)
colnames(df_total)

--------------------------------------------------------------------------------

# - Count of number of properties in different cantons

# Counting properties per Canton and arranging them from highest to lowest
properties_per_canton <- df_total %>%
  group_by(Canton) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count)) # Arrange in descending order of count

# Creating the vertical bar chart with smaller data labels
ggplot(properties_per_canton, aes(x = reorder(Canton, -Count), y = Count)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black") +
  geom_text(aes(label = Count), vjust = -0.5, color = "black", size = 2.2) + # Data labels above bars
  labs(title = "Properties per Canton", x = "Canton", y = "Count of Properties") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1), # Rotate x-axis labels for better readability
        plot.title = element_text(hjust = 0.5)) # Center the plot title

--------------------------------------------------------------------------------
  
  ### Prizes ###
  
--------------------------------------------------------------------------------
  
# - What is the distribution of rental prices in different cantons?

canton_order <- df_total %>%
  group_by(Canton) %>%
  summarise(Average_Price_Gross = mean(Price_Gross, na.rm = TRUE)) %>%
  arrange(desc(Average_Price_Gross)) %>%
  .$Canton

# Adjust the factor levels of Canton based on the calculated order
df_total$Canton <- factor(df_total$Canton, levels = canton_order)

# Plot with cantons ordered by average rental price
ggplot(df_total, aes(x = Canton, y = Price_Gross)) +
  stat_summary(fun = "mean", geom = "bar", fill = "skyblue", color = "black") +
  labs(title = "Average Rental Price per Canton", x = "Canton", y = "Average Rental Price (CHF)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

--------------------------------------------------------------------------------
  
# - What is the trend in rental prices over time (based on FirstDay_Online)?
  
# Filter per year 2021 and 2022
df_filtered_2021_2022 <- df_total %>%
filter(Year %in% c(2021, 2022))

# Create an Average Price Gross of 2021 and 2022
df_monthly_avg_2021_2022 <- df_filtered_2021_2022 %>%
  group_by(Year, Month_Year) %>%
  summarise(Average_Price = mean(Price_Gross, na.rm = TRUE)) %>%
  arrange(Year, Month_Year)

# Plot
ggplot(df_monthly_avg_2021_2022, aes(x = Month_Year, y = Average_Price, group = Year, color = as.factor(Year))) +
  geom_line() +
  scale_x_date(date_breaks = "1 month", date_labels = "%B") +
  scale_color_manual(values = c("2021" = "skyblue", "2022" = "darkblue")) +
  labs(title = "Over Time in Rental Prices ",
       x = "Month",
       y = "Average Gross Price (CHF)",
       color = "Year") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        legend.position = "bottom")


--------------------------------------------------------------------------------
  
  # - Are there differences in rental prices between different customer segments?
  
  # Option 1
  ggplot(df_total, aes(x = Customer_Segment, y = Price_Gross, fill = Customer_Segment)) +
  geom_boxplot(outlier.size = 1.5, alpha = 0.7) + 
  scale_fill_brewer(palette = "Pastel1") + 
  coord_cartesian(ylim = c(0, quantile(df_total$Price_Gross, 0.95, na.rm = TRUE))) + 
  labs(title = "Rental Prices by Customer Segment", x = "Customer Segment", y = "Gross Price (CHF)") +
  theme_minimal() +
  theme(legend.position = "none") 

# Option 2
ggplot(df_total, aes(x = Customer_Segment, y = Price_Gross)) +
  geom_boxplot(outlier.size = 1, aes(fill = Customer_Segment)) + 
  scale_y_log10(limits = c(100, NA)) + 
  scale_fill_brewer(palette = "Pastel1", guide = FALSE) + 
  labs(title = "Rental Prices by Customer Segment", x = "Customer Segment", y = "Gross Price (CHF)") +
  theme_minimal() +
  theme(legend.position = "none")

--------------------------------------------------------------------------------
  
  # Histogram for Price_Gross
  ggplot(df_total, aes(x = Price_Gross)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Rental Prices", x = "Gross Price (CHF)", y = "Frequency") +
  theme_minimal()

--------------------------------------------------------------------------------
  
  ### Property Size ###
  
--------------------------------------------------------------------------------

# - Is there a correlation between the size of the property (in m2) and the rental price?
  
# We sleect the Top Ten Cantons
top_10_cantons <- c("ZH", "VD", "AG", "SG", "BE", "TI", "LU", "TG", "BS", "ZG")
top_5_cantons <- c("ZH", "VD", "AG", "SG", "BE")

# Filter the dataset to include only the top cantons
df_top_10_cantons <- df_total %>%
  filter(Canton %in% top_10_cantons) %>%
  filter(Price_Gross <= 500000, Size_m2 <= 300) # Apply filters for Price_Gross and Size_m2

# Filter the dataset to include only the top cantons
df_top_5_cantons <- df_total %>%
  filter(Canton %in% top_5_cantons) %>%
  filter(Price_Gross <= 500000, Size_m2 <= 300) # Apply filters for Price_Gross and Size_m2

# Create a manual pastel color palette
pastel_colors <- c("ZH" = "#bdb2ff",  # Pastel blue
                   "VD" = "#ffd6a5",  # Lighter pastel blue
                   "AG" = "#b4f8c8",  # Pastel cyan
                   "SG" = "#ade8f4",  # Lighter pastel cyan
                   "BE" = "#ffafcc",  # Pastel red
                   "TI" = "#bde0fe",  # Pastel orange
                   "LU" = "#90e0ef",  # Pastel green
                   "TG" = "#a0c4ff",  # Another shade of pastel blue
                   "BS" = "#a1c9f4",  # Pastel purple
                   "ZG" = "#ffc6ff") # Pastel pink

# Scatter Plot TOP 10
ggplot(df_top_10_cantons, aes(x = Size_m2, y = Price_Gross)) +
  geom_point(aes(color = Canton), size = 0.8, alpha = 0.8) + # Smaller points with size 1
  scale_color_manual(values = pastel_colors) +
  geom_smooth(method = "lm", color = "red", size = 0.5, se = FALSE) +
  labs(title = "Correlation Between Property Size and Rental Price", x = "Size (m²)", y = "Gross Price (CHF)") +
  theme_minimal() +
  scale_y_log10(labels = scales::comma) # Apply logarithmic scale to y-axis

# Scatter Plot TOP 5
ggplot(df_top_5_cantons, aes(x = Size_m2, y = Price_Gross)) +
  geom_point(aes(color = Canton), size = 0.8, alpha = 0.8) + # Smaller points with size 1
  scale_color_manual(values = pastel_colors) +
  geom_smooth(method = "lm", color = "red", size = 0.5, se = FALSE) +
  labs(title = "Correlation Between Property Size and Rental Price", x = "Size (m²)", y = "Gross Price (CHF)") +
  theme_minimal() +
  scale_y_log10(labels = scales::comma) # Apply logarithmic scale to y-axis

--------------------------------------------------------------------------------

# Histogram for Size_m2
ggplot(df_total, aes(x = Size_m2)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Property Size", x = "Size (m²)", y = "Frequency") +
  theme_minimal()

ggplot(df_total, aes(x = Size_m2, y = Price_Gross)) +
  geom_point(aes(color = Category)) + # Color code by property category
  labs(title = "Price vs. Size of Property", x = "Size (m²)", y = "Gross Price (CHF)") +
  theme_minimal()

--------------------------------------------------------------------------------
  
  ### Number of rooms ###

--------------------------------------------------------------------------------
  
# - How does the number of rooms affect the rental price?

# Apply filters to remove extreme prices for better visualization
  df_filtered <- df_total %>%
  filter(Price_Gross <= 500000) %>%
  mutate(Nr_rooms = as.factor(Nr_rooms)) # Treat number of rooms as a factor

# Create the scatter plot without differentiating by canton
ggplot(df_filtered, aes(x = Nr_rooms, y = Price_Gross)) +
  geom_point(alpha = 0.6, size = 1, color = "skyblue") +
  geom_smooth(method = "lm", color = "red", se = FALSE, size = 0.5) +
  labs(title = "Effect of Number of Rooms on Rental Price", x = "Number of Rooms", y = "Gross Price (CHF)") +
  theme_minimal() +
  scale_y_log10() # Apply logarithmic scale to y-axis

--------------------------------------------------------------------------------
  
# Histogram for Nr_rooms
ggplot(df_total, aes(x = Nr_rooms)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Number of Rooms", x = "Number of Rooms", y = "Frequency") +
  theme_minimal()

--------------------------------------------------------------------------------
  
# - How does the GDP per capita of a canton relate to the average rental price in that canton?

# Plot with top 5 cantons highlighted
ggplot(df_top_5_cantons, aes(x = GDP_per_Capita, y = Price_Gross)) +
  geom_point(aes(color = Canton), size = 2) +  # Use a smaller point size for clarity
  geom_smooth(method = "lm", color = "red", se = FALSE) +  # Add a linear model without the confidence interval
  scale_color_manual(values = pastel_colors) +  # Corrected this line by removing the extra parenthesis
  scale_y_continuous(trans = 'log10', labels = scales::comma) +  # Use log10 transformation if the range is wide
  labs(title = "GDP per Capita vs. AVG Rental Price",
       x = "GDP per Capita",
       y = "Gross Price (CHF)",
       color = "Canton") +
  theme_minimal()

--------------------------------------------------------------------------------

  ### Population ###
  
--------------------------------------------------------------------------------
  
# - Is there a correlation between the population density of a canton and rental prices?

ggplot(df_total, aes(x = Population, y = Price_Gross)) +
  geom_point(alpha = 0.5) +  # Set transparency to see overlapping points
  scale_x_log10() +  # Log-transform the X axis
  scale_y_log10() +  # Log-transform the Y axis
  geom_smooth(method = "lm", se = FALSE) +  # Linear model without confidence interval
  labs(title = "Correlation between Population Density and Rental Prices",
       x = "Population",
       y = "Rental Price (CHF)") +
  theme_minimal()

--------------------------------------------------------------------------------
  
# Define your thresholds for what you consider an outlier
population_density_threshold <- quantile(df_total$Population, 0.95, na.rm = TRUE)
rental_price_threshold <- quantile(df_total$Price_Gross, 0.95, na.rm = TRUE)

# Filter out extreme outliers
df_filtered <- df_total %>%
  filter(Population <= population_density_threshold, Price_Gross <= rental_price_threshold)

# Now create the plot with filtered data
ggplot(df_filtered, aes(x = Population, y = Price_Gross)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +  # Linear model without confidence interval
  labs(title = "Correlation between Population Density and Rental Prices",
       x = "Population Density",
       y = "Rental Price (CHF)") +
  theme_minimal()

--------------------------------------------------------------------------------
  
# Population per Canton

canton_order <- df_total %>%
  group_by(Canton) %>%
  summarise(Population = mean(Population, na.rm = TRUE)) %>%
  arrange(desc(Population)) %>%
  .$Canton

# Adjust the factor levels of Canton based on the calculated order
df_total$Canton <- factor(df_total$Canton, levels = canton_order)

# Plot with cantons ordered by average rental price
ggplot(df_total, aes(x = Canton, y = Population)) +
  stat_summary(fun = "mean", geom = "bar", fill = "skyblue", color = "black") +
  labs(title = "Population per Canton", x = "Canton", y = "Population") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))





