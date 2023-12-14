
setwd("/Users/user/Desktop/metadata_flow/MELVILLE")


# Function to cut up the route into 50m transects and save them
process_file <- function(filename, dive_number) {
  data <- read.csv(filename)
  data$transect <- cut(data$cumulative_distance, 
                       breaks=seq(0, max(data$cumulative_distance), by=50), 
                       include.lowest=TRUE, 
                       labels=FALSE)
  list_of_transects <- split(data, data$transect)
  
  save_path <- "/Users/user/Desktop/metadata_flow/MELVILLE/melville_50m_transects" # specify your desired path here
  
  for (i in seq_along(list_of_transects)) {
    transect_name <- paste0("dive", dive_number, "transect", i, ".csv")
    write.csv(list_of_transects[[i]], file = transect_name, row.names = FALSE)
  }
}

for (filename in files_to_process) {
  tryCatch(
    {
      dive_number <- gsub(".*dive([0-9]+).*", "\\1", basename(filename))
      process_file(filename, dive_number)
    },
    error = function(e) {
      cat("Error processing file:", filename, "\n")
      cat("Error message:", conditionMessage(e), "\n")
    }
  )
}


files_to_process <- list.files(path = "/Users/user/Desktop/metadata_flow/MELVILLE/melville_interpolated", 
                               pattern = "\\.csv$", 
                               full.names = TRUE)


# Extract dive number from filenames and process each file
for (filename in files_to_process) {
  dive_number <- gsub(".*dive([0-9]+).*", "\\1", basename(filename))
  process_file(filename, dive_number)
}

setwd("/Users/user/Desktop/metadata_flow/MELVILLE/melville_interpolated")

# Function to cut up the route into 50m transects and save them
process_file <- function(filename) {
  data <- read.csv(filename)
  data$transect <- cut(data$cumulative_distance, 
                       breaks=seq(0, max(data$cumulative_distance), by=50), 
                       include.lowest=TRUE, 
                       labels=FALSE)
  list_of_transects <- split(data, data$transect)
  
  save_path <- "/Users/user/Desktop/metadata_flow/MELVILLE/melville_50m_transects" # specify your desired path here
  
  dive_number <- gsub(".*dive([0-9]+).*", "\\1", basename(filename))
  file_number <- gsub(".*file([0-9]+)-.*", "\\1", basename(filename))
  
  for (i in seq_along(list_of_transects)) {
    transect_name <- paste0("dive", dive_number, "file", file_number, "transect", i, ".csv")
    write.csv(list_of_transects[[i]], file = file.path(save_path, transect_name), row.names = FALSE)
  }
}

files_to_process <- list.files(path = "/Users/user/Desktop/metadata_flow/MELVILLE/melville_interpolated", 
                               pattern = "\\.csv$", 
                               full.names = TRUE)

# Process each file
for (filename in files_to_process) {
  process_file(filename)
}




# 
# now calculating richness for each 

library(vegan)
library(ggplot2)

# write a function to calculate species richness of VME morphospecies for each transect 

calculate_species_richness <- function(df) {
  # Filter the dataframe to include only rows where 'label_hierarchy' contains the specified categories
  filtered_df <- df[grepl("Cnidaria", df$label_hierarchy) | grepl("Porifera", df$label_hierarchy) | grepl("Bryozoa", df$label_hierarchy) | grepl("Stalked crinoids", df$label_hierarchy), ]
  
  # Calculate richness as the number of unique species in the filtered dataframe
  richness <- length(unique(filtered_df$label_name))
  return(richness)
}

calculate_species_abundance <- function(df) { 
  # Filter the dataframe to include only rows where 'label_hierarchy' contains the specified categories
  filtered_df <- df[grepl("Cnidaria", df$label_hierarchy) | grepl("Porifera", df$label_hierarchy) | grepl("Bryozoa", df$label_hierarchy) | grepl("Stalked crinoids", df$label_hierarchy), ]
  
  # Calculate richness as the number of unique species in the filtered dataframe
  abundance <- length(filtered_df$label_name)
  return(abundance)
}



#function to calculate environmental averages

calculate_environmental_averages <- function(df) {
  avg_temp <- mean(df$CTD.Temperature, na.rm = TRUE)
  avg_pressure <- mean(df$CTD.Pressure, na.rm = TRUE)
  avg_salinity <- mean(df$CTD.Salinity, na.rm = TRUE)
  avg_depth <- mean(df$depth, na.rm = TRUE)
  avg_gradient <- mean(df$slope, na.rm = TRUE)
  
  
  # find the most common substrate for each transect 
  
  substrate_counts <- table(df$substrate)
  if (length(substrate_counts) == 0) {
    most_common_substrate <- "Unknown"
  } else {
    most_common_substrate <- names(substrate_counts[which.max(substrate_counts)])
  }
  
  # Return as a data frame
  data.frame(AverageTemperature = avg_temp, 
             AveragePressure = avg_pressure, 
             AverageSalinity = avg_salinity, 
             AverageDepth = avg_depth, 
             AverageGradient = avg_gradient,
             MostCommonSubstrate = most_common_substrate)
}


process_transect <- function(file_path) {
  data <- read.csv(file_path)
  richness <- calculate_species_richness(data)
  abundance <- calculate_species_abundance(data)
  env_averages <- calculate_environmental_averages(data)
  
  transect_info <- basename(file_path)  # Extract transect information
  
  # Combine richness and environmental averages
  cbind(Transect = transect_info, Richness = richness, Abundance = abundance, env_averages)
}

# Directory containing transect files
transect_directory <- "/Users/user/Desktop/metadata_flow/MELVILLE/melville_50m_transects"
# Update with your directory path

transect_files <- list.files(transect_directory, full.names = TRUE)
transect_data <- lapply(transect_files, process_transect)

melville_transect_summary <- do.call(rbind, transect_data)
print(melville_transect_summary)


# add a fishing impact column 

melville_transect_summary$LostFishingGear <- NA
melville_transect_summary$SAI_Evidence <- NA

melville_transect_summary$LostFishingGear<- rep('N', nrow(melville_transect_summary))
melville_transect_summary$SAI_Evidence<- rep('N', nrow(melville_transect_summary))

# rubble refers to scleractinian rubble 

# List of target Transect values
target_transects <- paste0('dive8transect_', 1:31)

# Set 'SAI_Evidence' to 'Y' for target Transect values
for (transect in target_transects) {
  melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == transect] <- 'Y'
}

# Evidence of SAI (significant adverse impact)

melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_1.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_2.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_3.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_4.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_5.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_6.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_7.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_8.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_9.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_10.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_11.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_12.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_13.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_14.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_15.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_16.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_17.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_18.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_19.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_20.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_21.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_22.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_23.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_24.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_25.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_26.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_27.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_28.csv'] <- 'Y' # rubble and trawling scars 
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_29.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_30.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive8transect_31.csv'] <- 'Y' # rubble

melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_1.csv'] <- 'Y' # rubble and trawling scars 
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_2.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_3.csv'] <- 'Y' # rubble and trawling scars 
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_4.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_5.csv'] <- 'Y' # rubble and trawling scars 
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_6.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_7.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_9.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_10.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive9transect_12.csv'] <- 'Y' # rubble



melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_10.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_2.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_3.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_6.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_7.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_9.csv'] <- 'Y' # rubble and trawling scars
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_10.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_11.csv'] <- 'Y' # rubble
melville_transect_summary$SAI_Evidence[melville_transect_summary$Transect == 'dive10transect_12.csv'] <- 'Y' # rubble

# lost fishing gear 

melville_transect_summary$LostFishingGear[melville_transect_summary$Transect == 'dive8transect_24.csv'] <- 'Y' # rope and lobster pots 
melville_transect_summary$LostFishingGear[melville_transect_summary$Transect == 'dive8transect_15.csv'] <- 'Y' # lobster pot 
melville_transect_summary$LostFishingGear[melville_transect_summary$Transect == 'dive8transect_31.csv'] <- 'Y' # anchor 

melville_transect_summary$LostFishingGear[melville_transect_summary$Transect == 'dive9transect_1.csv'] <- 'Y' # rope  


View(melville_transect_summary)

# removing transects that contain no data 

melville_transect_summary <- subset(melville_transect_summary, MostCommonSubstrate != "Unknown")

melville_transect_summary$Seamount <- 'Melville Bank'


# export dataframe to a csv 
write.csv(melville_transect_summary, "/Users/user/Desktop/metadata_flow/SEAMOUNT_TRANSECTS/melville_transect_summary.csv", row.names=FALSE)

