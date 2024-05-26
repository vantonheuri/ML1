--------------------------------------------------------------------------------
  
# Generalised Additive Model
  
--------------------------------------------------------------------------------

# Install libraries

library(readr)
library(readxl)
library(ggplot2)
library(mgcv)
library(dplyr)
library(caret)

--------------------------------------------------------------------------------

# Load necessary libraries

# Reading in data
d.properties <- read_excel("data/data_cleaned/data_total_model.xlsx")
str(d.properties)
head(d.properties)

--------------------------------------------------------------------------------
# Plotting data
gg.density.site <- ggplot(data = d.properties, mapping = aes(y = Price_Gross, x = Size_m2)) + 
  geom_point()

gg.density.site + geom_smooth()

--------------------------------------------------------------------------------
# Fit a basic linear model
lm.properties.1 <- lm(Price_Gross ~ Size_m2, data = d.properties)
summary(lm.properties.1)

# p-value (Pr(>|t|)): < 2e-16, indicating very high significance (p < 0.001).
# Multiple R-squared: 0.08348. This suggests that approximately 8.35% of the variability in Price_Gross can be explained by Size_m2.

--------------------------------------------------------------------------------
  
# Fit a quadratic model
lm.properties.2 <- lm(Price_Gross ~ poly(Size_m2, 2), data = d.properties)
summary(lm.properties.2)

--------------------------------------------------------------------------------
  
# Compare linear and quadratic models
anova(lm.properties.1, lm.properties.2)

# Interpretation of the ANOVA table:
# Residual Degrees of Freedom (Res.Df): The quadratic model has one less degree of freedom than the linear model, indicating an additional parameter (the quadratic term).
# Residual Sum of Squares (RSS): The quadratic model has a lower RSS (946,506,359) compared to the linear model (1,080,715,226), indicating a better fit.
# Reduction in RSS: The improvement in fit by including the quadratic term is 134,208,867.
# F-statistic: A value of 136.41 indicates a significant improvement in fit.
# p-value: A p-value of < 2.2e-16 shows that the improvement is highly significant, indicating that the relationship between Size_m2 and Price_Gross includes a significant quadratic component.

# Conclusion:
# The comparison between the linear model (Price_Gross ~ Size_m2) and the quadratic model (Price_Gross ~ poly(Size_m2, 2)) shows that adding the quadratic term significantly improves the model fit. This suggests that the relationship between Size_m2 and Price_Gross is not simply linear, but has a significant quadratic component.

--------------------------------------------------------------------------------
  
# Next Steps:
# Given that the quadratic term is significant, the next steps would be:
# - Consider higher-order polynomial terms to see if a cubic or other relationship can provide a better fit.
# - Fit a GAM (Generalized Additive Model) to capture more complex non-linear relationships.
# - Include other predictor variables in the model to see how they affect the gross property price.

# Visualize the quadratic fit
gg.density.site + geom_smooth(method = "lm", formula = y ~ poly(x, degree = 2))

--------------------------------------------------------------------------------
# Fit a GAM
gam.properties <- gam(Price_Gross ~ s(Size_m2), data = d.properties)
summary(gam.properties)

# Visualize the GAM fit
plot(gam.properties, residuals = TRUE, cex = 2)

# Recommendations:
# - Focus on the Relevant Range: When making predictions or analyses about Price_Gross, it is safer to focus on properties up to 250 m², where the model is more reliable.
# - Collect More Data: If it is important to understand price behavior for larger properties, consider collecting more data in that range to improve model accuracy.
# - Model Validation: Validate the model using techniques such as cross-validation to ensure the fit is adequate in the range where there are more data.
# - Alternative Models: Consider other models that can better handle the scarcity of data in the larger property region or use regularization techniques that can help improve model stability in the presence of high variance.

--------------------------------------------------------------------------------
  
# Fit a GAM with multiple predictors
gam.properties.full <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density, data = d.properties)
summary(gam.properties.full)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.full, residuals = TRUE, cex = 2)

# Model Fit Measures:
# Adjusted R-squared: 0.413 (41.3% of the variability in Price_Gross explained by the model)
# Deviance explained: 41.9%
# GCV (Generalized Cross-Validation score): 726,970
# Scale estimation: 718,570
# Number of Observations (n): 965

# Conclusion:
# - Model Significance: The terms Days_Difference and Nr_rooms are highly significant. GDP_per and Population are moderately significant. Area_km2 and Density are not significant. The smooth term s(Size_m2) is highly significant and captures an important non-linear relationship.
# - Model Flexibility: The smooth term s(Size_m2) has an edf of 5.146, suggesting sufficient flexibility to capture the non-linear relationship between Size_m2 and Price_Gross.
# - Goodness of Fit: The adjusted R-squared of 0.413 indicates that the model explains approximately 41.3% of the variability in property prices, which is a considerable improvement over simpler models.

--------------------------------------------------------------------------------
  
# Filter data to include only properties with Size_m2 < 300
d.properties.filtered <- d.properties %>% filter(Size_m2 < 300)

# Fit the GAM with filtered data
gam.properties.filtered <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density, data = d.properties.filtered)

# Summary of the filtered model
summary(gam.properties.filtered)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.filtered, residuals = TRUE, cex = 2)

--------------------------------------------------------------------------------
  

# Transform the Size_m2 variable
d.properties <- d.properties %>% mutate(log_Size_m2 = log(Size_m2))

# Fit the GAM with the transformed variable
gam.properties.log <- gam(Price_Gross ~ s(log_Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density, data = d.properties)

# Summary of the model with the log transformation
summary(gam.properties.log)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.log, residuals = TRUE, cex = 2)

--------------------------------------------------------------------------------

# Fit the GAM with interactions
gam.properties.interaction <- gam(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by=Nr_rooms), data = d.properties)

# Summary of the model with interactions
summary(gam.properties.interaction)

# Visualize the effects of each predictor
par(mfrow = c(2, 2))  # Set plot layout
plot(gam.properties.interaction, residuals = TRUE, cex = 2)

# Perform cross-validation
set.seed(123)
train.control <- trainControl(method = "cv", number = 10)
gam.fit <- train(Price_Gross ~ s(Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density, data = d.properties, method = "gam", trControl = train.control)
print(gam.fit)

--------------------------------------------------------------------------------

# Filter data for Size_m2 < 300
d.properties.filtered <- d.properties %>% filter(Size_m2 < 300)

# Transform the Size_m2 variable
d.properties.filtered <- d.properties.filtered %>% mutate(log_Size_m2 = log(Size_m2))

# Fit the GAM with the transformed variable and interaction
gam.properties.combined <- gam(Price_Gross ~ s(log_Size_m2) + Days_Difference + Nr_rooms + GDP_per + Population + Area_km2 + Density + s(Size_m2, by = Nr_rooms), data = d.properties.filtered)

# Summary of the combined model
summary(gam.properties.combined)

# Visualize the smooth term
par(mfrow = c(2, 2))
plot(gam.properties.combined, residuals = TRUE, cex = 2)

  
  



  