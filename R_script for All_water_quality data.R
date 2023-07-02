#First Install dbhydroR package 
library(dbhydroR)
library(data.table)

station_ids <- c("L001", "L004", "L005", "L006", "L007", "L008", "LZ40",
                 "S65E", "S84", "S71", "S72", "S191", "S127", "S133", "S4",
                 "CULV10A", "FECSR78", "S154", "S308C","CLV10A", "EASTSHORE",
                 "FEBIN", "FEBOUT", "KBARSE", "KISSR0.0")
date_min <- "1950-01-01"
date_max <- format(Sys.Date(), "%Y-%m-%d")
test_names <- c("ALKALINITY, TOT, CACO3",
                "AMMONIA-N",
                "ANATOXIN-A",
                "ARSENIC, TOTAL",
                "BARIUM, DISSOLVED",
                "CADMIUM, DISSOLVED",
                "CADMIUM, TOTAL",
                "CALCIUM",
                "CALCIUM, TOTAL",
                "CARBON, DISSOLVED ORGANIC",
                "CARBON, TOTAL",
                "CARBON, TOTAL INORGANIC",
                "CARBON, TOTAL ORGANIC",
                "CAROTENOIDS",
                "CHLORIDE",
                "CHLOROPHYLL-A",
                "CHLOROPHYLL-A(LC)",
                "CHLOROPHYLL-A, CORRECTED",
                "CHLOROPHYLL-B",
                "CHLOROPHYLL-B (LC)",
                "CHLOROPHYLL-C",
                "CHROMIUM, DISSOLVED",
                "COBALT, DISSOLVED",
                "COLOR",
                "COPPER, DISSOLVED",
                "COPPER, TOTAL",
                "CYLINDROSPERMOPSIN",
                "DEPTH, TOTAL",
                "DESMETHYL MICROCYSTIN LR",
                "DISSOLVED OXYGEN",
                "FIXED SUSPENDED SOLIDS",
                "GROSS PRIMARY PROD. VOL.",
                "HARDNESS AS CACO3",
                "IRON, DISSOLVED",
                "IRON, TOTAL",
                "KJELDAHL NITROGEN, DIS",
                "KJELDAHL NITROGEN, TOTAL",
                "LEAD, DISSOLVED",
                "LEAD, TOTAL",
                "MAGNESIUM",
                "MANGANESE, DISSOLVED",
                "MERCURY, TOTAL",
                "MICROCYSTIN HILR",
                "MICROCYSTIN HTYR",
                "MICROCYSTIN LA",
                "MICROCYSTIN LF",
                "MICROCYSTIN LR",
                "MICROCYSTIN LW",
                "MICROCYSTIN LY",
                "MICROCYSTIN RR",
                "MICROCYSTIN WR",
                "MICROCYSTIN YR",
                "NEOSAXITOXIN",
                "NET PRIMARY PROD. VOLUME",
                "NICKEL, DISSOLVED",
                "NITRATE+NITRITE-N",
                "NITRATE-N",
                "NITRITE-N",
                "NO BOTTLE SAMPLE",
                "NODULARIN-R",
                "ORP",
                "PH, FIELD",
                "PH, LAB",
                "PHEOPHYTIN",
                "PHEOPHYTIN-A(LC)",
                "PHOSPHATE, DISSOLVED AS P",
                "PHOSPHATE, ORTHO AS P",
                "PHOSPHATE, TOTAL AS P",
                "POTASSIUM",
                "RESP. PLANKTONIC VOLUME",
                "SALINITY",
                "SAXITOXIN",
                "SECCHI DISK DEPTH",
                "SILICA",
                "SODIUM",
                "SP CONDUCTIVITY, FIELD",
                "SP CONDUCTIVITY, LAB",
                "STRONTIUM, DISSOLVED",
                "SULFATE",
                "Temperature",
                "TOTAL DISSOLVED SOLIDS",
                "TOTAL NITROGEN",
                "TOTAL SUSPENDED SOLIDS",
                "TURBIDITY",
                "VOLATILE SUSPENDED SOLIDS",
                "ZINC, DISSOLVED",
                "ZINC, TOTAL"
)

for (station_id in station_ids) {
  water_quality_data <- get_wq(station_id = station_id,
                               date_min = date_min,
                               date_max = date_max,
                               test_name = test_names)
  
  # Create a new data frame to store the desired format
  new_data <- data.frame(
    date = character(),
    station = character(),
    test_name = character(),
    unit = character(),
    value = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Loop through the columns of the original data and reshape it to the desired format
  for (col in sort(colnames(water_quality_data)[-1])) {
    parameter <- col
    data <- na.omit(data.frame(date = water_quality_data$date, value = water_quality_data[[col]], stringsAsFactors = FALSE))
    data$parameter <- parameter
    # Extract station, test name, and unit from the parameter column
    data$station_id <- gsub("^(.*?)_.*", "\\1", parameter)
    data$test_name <- gsub(".*_(.*?)_.*", "\\1", parameter)
    data$unit <- gsub(".*_(.*?)$", "\\1", parameter)
    # Reorder the columns in the data frame
    data <- data[, c("date", "station_id", "test_name", "unit", "value")]
    new_data <- rbind(new_data, data)
  }
  
  
  # Convert the date column to proper date format
  new_data$date <- as.Date(new_data$date, format = "%m/%d/%Y")
  
  # Sort the data by date and then by parameter
  new_data <- new_data[order(new_data$date, new_data$test_name), ]
  
  # Convert the date column back to the desired format
  new_data$date <- format(new_data$date, "%m/%d/%Y")
  
  # Sort the data by parameter in alphabetical order
  new_data <- new_data[order(new_data$test_name), ]
  
  # Write the data to a CSV file
  file_name <- paste0("dbhydro_waterquality_", station_id, ".csv")
  write.csv(new_data, file = file_name, row.names = FALSE)
}

#combining all the different station_id files
combined_data <- data.table()

for (station_id in station_ids) {
  file_name <- paste0("dbhydro_waterquality_", station_id, ".csv")
  
  if (file.exists(file_name)) {
    data <- fread(file_name)
    data$station_id <- station_id
    
    combined_data <- rbindlist(list(combined_data, data), fill = TRUE)
  }
}

# Write the combined data to a CSV file
write.csv(combined_data, file = "combined_dbhydro_waterquality_data.csv", row.names = FALSE)
