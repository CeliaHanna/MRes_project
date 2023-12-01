# splitting the interpolated coral dives into 50m transects 

library(dplyr)


setwd("/Users/user/Desktop/metadata_flow/coral_50m_transects")

# Function to cut up the route into 50m transects and save them
process_file <- function(filename, dive_number) {
  data <- read.csv(filename)
  data$transect <- cut(data$cumulative_distance, 
                       breaks=seq(0, max(data$cumulative_distance), by=50), 
                       include.lowest=TRUE, 
                       labels=FALSE)
  list_of_transects <- split(data, data$transect)
  
  save_path <- "/Users/user/Desktop/metadata_flow/coral_50m_transects" # specify your desired path here
  
  for (i in seq_along(list_of_transects)) {
    transect_name <- paste0("dive", dive_number, "transect", i, ".csv")
    write.csv(list_of_transects[[i]], file = transect_name, row.names = FALSE)
  }
}

files_to_process <- list.files(path = "/Users/user/Desktop/metadata_flow/coral_interpolated", 
                               pattern = "\\.csv$", 
                               full.names = TRUE)

# Extract dive number from filenames and process each file
for (filename in files_to_process) {
  dive_number <- gsub(".*dive([0-9]+).*", "\\1", basename(filename))
  process_file(filename, dive_number)
}

# 
# transects are now saved as CSVs in the coral_to_interpolate 