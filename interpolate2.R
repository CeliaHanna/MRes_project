
# Load necessary libraries
library(geosphere)
library(dplyr)

#NB this script saves it into wrong directory then i dragged it to interpolated file 

# Function to calculate 3D distance between two points using their lat, lon, and depth
calculate_3d_distance <- function(lat1, lon1, depth1, lat2, lon2, depth2) {
  surface_distance <- distHaversine(c(lon1, lat1), c(lon2, lat2))
  depth_difference <- abs(depth1 - depth2)
  sqrt(surface_distance^2 + depth_difference^2)
}

# Function to find the nearest point
find_nearest_point <- function(lat, lon, depth, df) {
  distances <- sqrt((df$lat - lat)^2 + (df$lon - lon)^2 + (df$depth - depth)^2)
  return(which.min(distances))
}


# merge files that are the same dive and are consecutive 

setwd("/Users/user/Desktop/metadata_flow/MELVILLE/completed_metadata_files")  # Set the working directory to where your CSV files are stored
output_directory <- "/Users/user/Desktop/metadata_flow/MELVILLE/melville_interpolated"

files_to_merge <- c("12760-dive5-file1.csv", "12761-dive5-file2.csv")
dive5 <- lapply(files_to_merge, read.csv) %>% bind_rows
# 
files_to_merge <- c("12187-dive1-file4.csv", "12229-dive1-file5.csv")
dive1 <- lapply(files_to_merge, read.csv) %>% bind_rows
# 
# files_to_merge <- c("12461-dive3-file4.csv", "12758-dive3-file5.csv")
dive3 <- lapply(files_to_merge, read.csv) %>% bind_rows
 
# files_to_merge <- c("12435-dive2-file4.csv", "12759-dive2-file5.csv")
dive2 <- lapply(files_to_merge, read.csv) %>% bind_rows
# 
# # Create the full path for the new file
# output_filename <- paste0(output_directory, "/dive2.csv")
# 
# # Write the merged data frame to a CSV file
# write.csv(dive2, output_filename, row.names = FALSE)

# List of file paths
# file_paths <- c("/Users/user/Desktop/metadata_flow/completed_metadata_files/12938-dive8-file5.csv",
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/12937-dive8-file3.csv",
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/12936-dive8-file2.csv", 
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/12145-dive10-file2.csv",
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/12144-dive10-file3.csv",
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/11841-dive9-file3.csv",
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/11774-dive9-file2.csv", 
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/11715-dive8-file4.csv", 
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/11505-dive8-file1.csv", 
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/dive8-file3-second.csv",
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/dive9-file3-second.csv",
                "/Users/user/Desktop/metadata_flow/completed_metadata_files/dive10-file2-second.csv")


# file_paths <- c("/Users/user/Desktop/metadata_flow/MELVILLE/melville_finaldives/DIVE7.csv", 
                "/Users/user/Desktop/metadata_flow/MELVILLE/melville_finaldives/DIVE8.csv", 
                "/Users/user/Desktop/metadata_flow/MELVILLE/melville_finaldives/DIVE9.csv", 
                "/Users/user/Desktop/metadata_flow/MELVILLE/melville_finaldives/DIVE10.csv") 

file_paths <- c("/Users/user/Desktop/metadata_flow/MELVILLE/completed_metadata_files/12938-dive8-file5.csv") 





# Loop over each file path
for (file_path in file_paths) {
  # Read CSV file
  data <- read.csv(file_path)
  
  # Convert relevant columns to numeric, add 'Type' column
  data$lon <- as.numeric(data$lon)
  data$lat <- as.numeric(data$lat)
  data$depth <- as.numeric(data$ROV.RovDepth)
  data$CTD.Temperature <- as.numeric(data$CTD.Temperature)
  data$CTD.Salinity <- as.numeric(data$CTD.Salinity)
  data$CTD.Pressure <- as.numeric(data$CTD.Pressure)
  data$slope <- as.numeric(data$slope_value)
  data$Type <- 'Original'
  
  # Create empty data frame for interpolated data
  interpolated_data <- data.frame(lon = numeric(), lat = numeric(), depth = numeric(),
                                  CTD.Temperature = numeric(), CTD.Salinity = numeric(), 
                                  CTD.Pressure = numeric(), slope = numeric(), 
                                  label_name = character(), label_hierarchy = character(), 
                                  Type = character(), cumulative_distance = numeric())
  
  cumulative_distance <- 0
  
  # Main loop for data interpolation
  for (i in 1:(nrow(data) - 1)) {
    distance_3d <- calculate_3d_distance(data$lat[i], data$lon[i], data$depth[i],
                                         data$lat[i + 1], data$lon[i + 1], data$depth[i + 1])
    n_points <- max(1, ceiling(distance_3d))
    
    for (j in 1:n_points) {
      fraction <- j / n_points
      lat_interp <- data$lat[i] + fraction * (data$lat[i + 1] - data$lat[i])
      lon_interp <- data$lon[i] + fraction * (data$lon[i + 1] - data$lon[i])
      depth_interp <- data$depth[i] + fraction * (data$depth[i + 1] - data$depth[i])
      temp_interp <- data$CTD.Temperature[i] + fraction * (data$CTD.Temperature[i + 1] - data$CTD.Temperature[i])
      salinity_interp <- data$CTD.Salinity[i] + fraction * (data$CTD.Salinity[i + 1] - data$CTD.Salinity[i])
      pressure_interp <- data$CTD.Pressure[i] + fraction * (data$CTD.Pressure[i + 1] - data$CTD.Pressure[i])
      slope_interp <- data$slope_value[i] + fraction * (data$slope_value[i + 1] - data$slope_value[i])
      
      if (j > 1) {
        cumulative_distance <- cumulative_distance + (distance_3d / n_points)
      }
      interpolated_row <- data.frame(lon = lon_interp, lat = lat_interp, depth = depth_interp,
                                     CTD.Temperature = temp_interp, CTD.Salinity = salinity_interp, 
                                     CTD.Pressure = pressure_interp, slope = slope_interp,
                                     label_name = NA, label_hierarchy = NA,
                                     Type = 'Interpolated', cumulative_distance = cumulative_distance)
      interpolated_data <- rbind(interpolated_data, interpolated_row)
    }
  }
  
  # Initialize columns for labels in interpolated_data
  interpolated_data$label_name <- NA
  interpolated_data$label_hierarchy <- NA
  interpolated_data$Substrate <- NA
  interpolated_data$video_duration <- NA
  
  # Assign labels to the nearest points
  for (i in 1:nrow(data)) {
    nearest_index <- find_nearest_point(data$lat[i], data$lon[i], data$depth[i], interpolated_data)
    interpolated_data$label_name[nearest_index] <- data$label_name[i]
    interpolated_data$label_hierarchy[nearest_index] <- data$label_hierarchy[i]
    interpolated_data$substrate[nearest_index] <- data$substrate[i]
    interpolated_data$video_duration[nearest_index] <- data$video_duration[i]
    interpolated_data$slope[nearest_index] <- data$slope_value[i]
  }
  
  # Write the output file for the current dataset
  output_file_path <- gsub(".csv", "_interpolated.csv", file_path)
  write.csv(interpolated_data, file = output_file_path, row.names = FALSE)
}

#     

