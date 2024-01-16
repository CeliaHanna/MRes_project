
process_file <- function(filename, dive_number, transect_count) {
  data <- read.csv(filename)
  
  # Handle NA values in cumulative_distance, if any
  data$cumulative_distance <- ifelse(is.na(data$cumulative_distance), 0, data$cumulative_distance)
  
  # Calculate the maximum distance, ensure it's greater than zero for cut function
  max_distance <- max(data$cumulative_distance, na.rm = TRUE)
  if (max_distance > 0) {
    data$transect <- cut(data$cumulative_distance, 
                         breaks=seq(0, max_distance, by=50), 
                         include.lowest=TRUE, 
                         labels=FALSE)
    list_of_transects <- split(data, data$transect)
    
    for (i in seq_along(list_of_transects)) {
      transect_name <- paste0("dive", dive_number, "_transect", transect_count, ".csv")
      write.csv(list_of_transects[[i]], file = paste0("/Users/user/Desktop/productivity_extracted/melville/melville_50m_transects/", transect_name), row.names = FALSE)
      transect_count <- transect_count + 1
    }
  } else {
    warning(paste0("No valid data in file: ", filename))
  }
  
  return(transect_count)
}

files_to_process <- list.files(path = "/Users/user/Desktop/productivity_extracted/melville/", 
                               pattern = "\\.csv$", 
                               full.names = TRUE)

transect_count <- 1

# Extract dive number and file number from filenames and process each file
for (filename in files_to_process) {
  dive_number <- gsub(".*dive([0-9]+).*", "\\1", basename(filename))
  transect_count <- process_file(filename, dive_number, transect_count)
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
  avg_productivity <- mean(df$PRODUCTIVITY_1, na.rm= TRUE)
  
  
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
             AverageProductivity = avg_productivity,
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
transect_directory <- "/Users/user/Desktop/productivity_extracted/melville/melville_50m_transects"
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

