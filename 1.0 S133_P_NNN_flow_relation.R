# Clear the workspace
rm(list = ls())

library(rio)
library(moments)
library(dbhydroR)
library(dplyr)
library(corrplot)
library(ggplot2)
library(MASS)
library(car)

file1 = import("water_quality_S133_NITRATE+NITRITE-N.csv", colClasses = c("NULL", "character", "numeric","NULL"))
file2 =import("S133_P_FLOW_cmd.csv", colClasses = c("NULL", "character", "numeric"))
colnames(file1)[1] <- "Date"
colnames(file2)[1] <- "Date"
merged_data <- merge(file1, file2, by = "Date", all = TRUE)
# Remove rows with 0 values in any column
merged_data <- merged_data %>%
  filter(if_all(everything(), ~. != 0))
# remove rows with missing values (NA) from the merged_data data frame,
merged_data <- merged_data[complete.cases(merged_data), ]

# Save merged_data as a CSV file
write.csv(merged_data, "merged_data_S133_Flow_NNN.csv", row.names = FALSE)
# Rename the columns
colnames(merged_data)[colnames(merged_data) == "S133_NITRATE+NITRITE-N_mg/L"] <- "S133_NITRATE_NITRITE_N_Ld_mg"
colnames(merged_data)[colnames(merged_data) == "S133_P_FLOW_cfs"] <- "S133_P_FLOW_cfd"
# Calculate new column
merged_data$S133_NITRATE_NITRITE_N_Ld_mg <- merged_data$S133_P_FLOW_cfd * merged_data$S133_NITRATE_NITRITE_N_Ld_mg* 1000
# Save updated merged_data as a CSV file
write.csv(merged_data, "merged_data_S133_Flow_NNN_updated.csv", row.names = FALSE)
# Check skewness
skewness_values <- sapply(merged_data[c("S133_NITRATE_NITRITE_N_Ld_mg", "S133_P_FLOW_cfd")], skewness)
print(skewness_values)

# Check kurtosis
kurtosis_values <- sapply(merged_data[c("S133_NITRATE_NITRITE_N_Ld_mg", "S133_P_FLOW_cfd")], kurtosis)
print(kurtosis_values)

# Set the plotting parameters
par(mfrow = c(1, 2))  # To display histograms in a 1x2 grid

# Histogram for S133_NITRATE_NITRITE_N_Ld_mg
hist(merged_data$S133_NITRATE_NITRITE_N_Ld_mg, col = 'red', probability = TRUE)
curve(dnorm(x, mean = mean(merged_data$S133_NITRATE_NITRITE_N_Ld_mg), sd = sd(merged_data$S133_NITRATE_NITRITE_N_Ld_mg)), 
      from = min(merged_data$S133_NITRATE_NITRITE_N_Ld_mg), to = max(merged_data$S133_NITRATE_NITRITE_N_Ld_mg), 
      col = 'black', add = TRUE, lwd = 3)



# Histogram for S133_P_FLOW_cfs
hist(merged_data$S133_P_FLOW_cfd, col = 'red', probability = TRUE)
curve(dnorm(x, mean = mean(merged_data$S133_P_FLOW_cfd), sd = sd(merged_data$S133_P_FLOW_cfd)), 
      from = min(merged_data$S133_P_FLOW_cfd), to = max(merged_data$S133_P_FLOW_cfd), 
      col = 'black', add = TRUE, lwd = 3)

par(mfrow=c(1,1))
# Calculate the correlation matrix for the parameter columns
correlation_matrix <- cor(merged_data[, -1])

# Print the correlation matrix
print(correlation_matrix)
# Visualize the correlation matrix using corrplot
corrplot(correlation_matrix, method = "color", type = "lower", tl.col = "black",addCoef.col = "red")
# Log transformation--> As it works best for right skewed data
merged_data[, -1] <- log(merged_data[, -1])
merged_data <- merged_data[complete.cases(merged_data), ]
# Save log merged_data as a CSV file
write.csv(merged_data, "log_merged_data_S133_Flow_NNN.csv", row.names = FALSE)
# Check skewness
skewness_values <- sapply(merged_data[c("S133_NITRATE_NITRITE_N_Ld_mg", "S133_P_FLOW_cfd")], skewness)
print(skewness_values)

# Check kurtosis
kurtosis_values <- sapply(merged_data[c("S133_NITRATE_NITRITE_N_Ld_mg", "S133_P_FLOW_cfd")], kurtosis)
print(kurtosis_values)

# Create a function to plot histogram with density plot
# Set the plotting parameters
par(mfrow = c(1, 2))  # To display histograms in a 1x2 grid

# Histogram for S133_NITRATE_NITRITE_N_Ld_mg
hist(merged_data$S133_NITRATE_NITRITE_N_Ld_mg, col = 'red', probability = TRUE)
curve(dnorm(x, mean = mean(merged_data$S133_NITRATE_NITRITE_N_Ld_mg), sd = sd(merged_data$S133_NITRATE_NITRITE_N_Ld_mg)), 
      from = min(merged_data$S133_NITRATE_NITRITE_N_Ld_mg), to = max(merged_data$S133_NITRATE_NITRITE_N_Ld_mg), 
      col = 'black', add = TRUE, lwd = 3)


# Histogram for S133_P_FLOW_cfs
hist(merged_data$S133_P_FLOW_cfd, col = 'red', probability = TRUE)
curve(dnorm(x, mean = mean(merged_data$S133_P_FLOW_cfd), sd = sd(merged_data$S133_P_FLOW_cfd)), 
      from = min(merged_data$S133_P_FLOW_cfd), to = max(merged_data$S133_P_FLOW_cfd), 
      col = 'black', add = TRUE, lwd = 3)


par(mfrow=c(1,1))

# Calculate the correlation matrix for the parameter columns
correlation_matrix <- cor(merged_data[, -1])

# Print the correlation matrix
print(correlation_matrix)
# Visualize the correlation matrix using corrplot
corrplot(correlation_matrix, method = "color", type = "lower", tl.col = "black",addCoef.col = "red")

# Specify initial values for a and b
initial_values <- list(a = 1, b = 1)

# Fit a non-linear regression model
model <- nls(S133_NITRATE_NITRITE_N_Ld_mg ~ a * S133_P_FLOW_cfd^b, data = merged_data, start = initial_values)

# Print the model summary
summary(model)

# Extract the estimated coefficients
a <- coef(model)["a"]
b <- coef(model)["b"]

# Print the non-linear equation
message("Non-linear equation: S133_NITRATE_NITRITE_N_Ld_mg =", a, "* S133_P_FLOW_cfd^", b)


# Make predictions on the merged_data
predictions <- fitted(model)

# Create a data frame with the actual and predicted values
plot_data <- data.frame(
  S133_P_FLOW_cfd = merged_data$S133_P_FLOW_cfd,
  Actual = merged_data$S133_NITRATE_NITRITE_N_Ld_mg,
  Predicted = predictions
)

# Plot actual vs predicted values
ggplot(plot_data, aes(x = S133_P_FLOW_cfd)) +
  geom_point(aes(y = Actual), color = "blue", size = 3) +
  geom_point(aes(y = Predicted), color = "red", size = 3) +
  labs(x = "S133_P_FLOW_cfd", y = "S133_NITRATE_NITRITE_N_Ld_mg") +
  ggtitle("Actual vs Predicted Values") +
  theme_minimal()

# Calculate the Root Mean Square Error (RMSE)
rmse <- sqrt(mean((merged_data$S133_NITRATE_NITRITE_N_Ld_mg - predictions)^2))
message("RMSE:", rmse)

# Fit the non-linear regression model
model <- nls(S133_NITRATE_NITRITE_N_Ld_mg ~ a * S133_P_FLOW_cfd^b, data = merged_data, start = initial_values)

# Get the predicted values from the model
predicted <- fitted(model)
# Calculate the total sum of squares (SST)
mean_actual <- mean(merged_data$S133_NITRATE_NITRITE_N_Ld_mg)
sst <- sum((merged_data$S133_NITRATE_NITRITE_N_Ld_mg - mean_actual)^2)

# Calculate the residual sum of squares (SSE)
sse <- sum((merged_data$S133_NITRATE_NITRITE_N_Ld_mg - predicted)^2)

# Calculate the R-squared value
rsquared <- 1 - (sse / sst)
# Non-Linear equation, RMSE and R-squared:
message("Non-linear equation: S133_NITRATE_NITRITE_N_Ld_mg =", a, "* S133_P_FLOW_cfd^", b)
message("RMSE:", rmse)
message("R-squared:", rsquared)

