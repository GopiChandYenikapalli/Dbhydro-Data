# Clear the workspace
rm(list = ls())
library(dbhydroR)

station_ids <- c("S4_P", "S65E","S65EX1_S", "S84_S","S84X_S", "S71_S", "S72_S", "S191_S", "S127_P", "S133_P","S154_C","S308_S", "FISHCR")
dbkeys <- get_dbkey(stationid = station_ids, stat = "MEAN", category = "SW", param = "FLOW",freq = "DA", detail.level = "full")
print(dbkeys)
dbkeys <- get_dbkey(stationid = station_ids, stat = "MEAN", category = "SW", param = "FLOW",freq = "DA", detail.level = "dbkey")
print(dbkeys)
#using dbkeys to manual input and delete dbkey starting with zero because there is no recorder for those
cat(paste('"', dbkeys, '"', sep = "", collapse = ", "))

#Paste dbkey and assign it a variable k
k <- c("WH036", "15641", "91371", "15637", "91377", "15629", "91401", "15639",
       "91429", "91474", "DJ239", "15630", "91608", "15631", "AL760", 
       "15633", "91668", "15634", "91675", "91686", "15636", "91687")
data <- get_hydro(dbkey = k, date_min = "1990-01-01", date_max = format(Sys.Date(), "%Y-%m-%d"))

# Divide all columns except "date" column by 35.31466669
data[, -1] <- data[, -1] / 35.31466669

# Add a new column as the sum of "S65E_FLOW_cfs" and "S65EX1_S_FLOW_cfs";S84_S_FLOW_cfs and S84X_S_FLOW_cfs
data$SUM_S65_FLOW_cfs <- data$S65E_FLOW_cfs + data$S65EX1_S_FLOW_cfs
data$SUM_S84_FLOW_cfs <- data$S84_S_FLOW_cfs + data$S84X_S_FLOW_cfs

# Print column names
column_names <- colnames(data)
print(column_names)

# Delete the columns "S65E_FLOW_cfs", "S65EX1_S_FLOW_cfs", "S84_S_FLOW_cfs", and "S84X_S_FLOW_cfs"
data <- data[, -c(9, 10, 13, 14)]

# Convert negative values to zero
data[, -1][data[, -1] < 0] <- 0


# Save the modified data in a CSV file
write.csv(data, file = "hydro_flow.csv", row.names = FALSE)
