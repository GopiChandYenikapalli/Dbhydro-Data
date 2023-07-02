# Clear the workspace
rm(list = ls())
library(dbhydroR)

#station_ids <- c("L001", "L005", "L006", "LZ40", "L OKEE")
#dbkeys <- get_dbkey(stationid = station_ids, stat = "MEAN", category = "SW", param = "STG",freq = "DA", detail.level = "full")
#print(dbkeys)
#dbkeys <- get_dbkey(stationid = station_ids, stat = "MEAN", category = "SW", param = "STG",freq = "DA", detail.level = "dbkey")
#print(dbkeys)
#using dbkeys to manual input and delete dbkey starting with zero because there is no recorder for those
#cat(paste('"', dbkeys, '"', sep = "", collapse = ", "))


dbkeys <- c("15611", "16022", "12509", "12519", "16265")

for (i in dbkeys) {
  # Retrieve data for the dbkey
  data <- get_hydro(dbkey = i, date_min = "1990-01-01", date_max = format(Sys.Date(), "%Y-%m-%d"))
  
  # Convert water level from feet to meters
  data[, -1] <- data[, -1] * 0.3048
  
  # Extract the column names excluding the date column
  column_names <- names(data)[-1]
  
  # Generate the filename based on the column names
  filename <- paste0("water_level_", gsub(" ", "_", sub("_[^_]*$", "", paste(column_names, collapse = "_"))), "_mt_NGVD29.csv")
  
  # Save data to a CSV file
  write.csv(data, file = filename)
  
  # Print a message indicating the file has been saved
  cat("CSV file", filename, "has been saved.\n")
  
  # Add a delay between requests
  Sys.sleep(10) # Wait for 10 seconds before the next iteration
}
