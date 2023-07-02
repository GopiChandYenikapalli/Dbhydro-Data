# Clear the workspace
rm(list = ls())

# Load the required libraries
library(rio)
library(dbhydroR)
library(lubridate)

# Specify the station IDs, date range, and test names
station_ids <- c("S4", "S65E", "S84", "S71", "S72", "S191", "S127", "S133", "S135","S154","S308C", "FECSR78")
date_min <- "1950-01-01"
date_max <- format(Sys.Date(), "%Y-%m-%d")
test_names <- c("NITRATE+NITRITE-N")

# Loop over the station IDs
for (station_id in station_ids) {
  # Retrieve water quality data for the current station ID
  water_quality_data <- get_wq(
    station_id = station_id,
    date_min = date_min,
    date_max = date_max,
    test_name = test_names
  )
  
  # Convert negative values to NA
  water_quality_data[water_quality_data < 0] <- NA
  
  # Calculate the number of days from the minimum date plus 8
  water_quality_data$days <- as.integer(difftime(water_quality_data$date, min(water_quality_data$date), units = "days")) + as.integer(format(min(water_quality_data$date), "%d"))
  
  # Generate the filename based on the station ID
  filename <- paste0("TN_", station_id, ".csv")
  
  # Save data to a CSV file
  write.csv(water_quality_data, file = filename)
  
  # Print a message indicating the file has been saved
  cat("CSV file", filename, "has been saved.\n")
}

