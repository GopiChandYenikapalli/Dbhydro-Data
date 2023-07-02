
library(dbhydroR)
library(data.table)
# Call get_hydro function with dbkey_values
dbkeys_value <- c("16027", "J0942", "16026", "16032", "16025", "16024", "16023", "12514", "J0940", "12513", "12516", "12512", "12510", "12911", "J0941", "12523", "12525", "12522", "12520", "13078", "J0943", "13079", "16266", "15649", "13080", "13077", "13076")
print(dbkeys_value)

for (i in dbkeys_value) {
  hyd_data <- get_hydro(dbkey = i, date_min = "2000-01-01", date_max = format(Sys.Date(), "%Y-%m-%d"))
  
  new_data <- data.frame(
    date = character(),
    station_id = character(),
    test_name = character(),
    unit = character(),
    value = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (col in sort(colnames(hyd_data)[-1])) {
    parameter <- col
    data <- na.omit(data.frame(date = hyd_data$date, value = hyd_data[[col]], stringsAsFactors = FALSE))
    data$parameter <- parameter
    data$station_id <- gsub("^(.*?)_.*", "\\1", parameter)
    data$test_name <- gsub(".*_(.*?)_.*", "\\1", parameter)
    data$unit <- gsub(".*_(.*?)$", "\\1", parameter)
    data <- data[, c("date", "station_id", "test_name", "unit", "value")]
    new_data <- rbind(new_data, data)
  }
  
  new_data$date <- as.Date(new_data$date, format = "%m/%d/%Y")
  new_data <- new_data[order(new_data$date, new_data$test_name), ]
  new_data$date <- format(new_data$date, "%m/%d/%Y")
  new_data <- new_data[order(new_data$test_name), ]
  
  file_name <- paste0("hyd_data_", unique(new_data$station_id), ".csv")
  write.csv(new_data, file = file_name, row.names = FALSE)
  # Add a delay of 3 seconds after each request
  Sys.sleep(10)
}



data <- get_hydro()
print(data)
# Extract information from the column name
data <- data %>%
  mutate(station_id = str_extract(colnames(.)[2], "^[^_]+"),
         parameter = str_extract(colnames(.)[2], "(?<=_)[^_]+(?=_)"),
         unit = str_extract(colnames(.)[2], "(?<=_)[^_]+$"),
         value = L001_AIRT_Degrees_Celsius) %>%
  select(date, station_id, parameter, unit, value)

# Save the modified output in a CSV file
write.csv(data, file = "hydro_data.csv", row.names = FALSE)
