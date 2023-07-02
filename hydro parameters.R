library(dbhydroR)

station_ids <- c("L001", "L004", "L005", "L006", "L007", "L008", "LZ40")
dbkeys <- get_dbkey(stationid = station_ids, stat = "MEAN", category = "WEATHER", freq = "DA", detail.level = "dbkey")
# Save the get_hydro output in a CSV file
writeLines(dbkeys_string, "dbkeys.csv")
cat(paste('"', dbkeys, '"', sep = "", collapse = ", "))
# Save the get_hydro output in a CSV file


# Call get_hydro function with dbkey_values

t =c("16027", "J0942", "16026", "16032", "16025", "16024", "16023", "12514",
     "J0940", "12513", "12516", "12512", "12510", "12911", "J0941", "12523", 
     "12525", "12522", "12520", "13078", "J0943", "13079", "16266", "15649", 
     "13080", "13077", "13076")
print(t)

data <- get_hydro(dbkey = t, date_min = "2000-01-01", date_max = format(Sys.Date(), "%Y-%m-%d"))

# Save the get_hydro output in a CSV file
write.csv(data, file = "hydro_data.csv", row.names = FALSE)


example("gethydro")
example("getdbkey")
example("getwq")
get_dbkey(stationid = c("L001"), category = "WEATHER",param = "WNDS", freq = "DA", detail.level = "dbkey")

rm(list = ls())
library(rio)
library(moments)
excel_data =import("hydro_data.csv")
print(excel_data)
# Load required libraries
library(tidyverse)

# Reshape the data
reshaped_data <- excel_data %>%
  pivot_longer(cols = -date, names_to = "parameter", values_to = "value") %>%
  separate(parameter, into = c("station_id", "parameter", "unit"), sep = "_", remove = FALSE) %>%
  select(date, station_id, parameter, unit, value)

# Print the reshaped data
print(reshaped_data)
write.csv(reshaped_data, file = "hydro_data_combind.csv", row.names = FALSE)
