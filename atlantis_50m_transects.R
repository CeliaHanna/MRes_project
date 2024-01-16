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
      write.csv(list_of_transects[[i]], file = paste0("/Users/user/Desktop/productivity_extracted/atlantis/atlantis_50m_transects/", transect_name), row.names = FALSE)
      transect_count <- transect_count + 1
    }
  } else {
    warning(paste0("No valid data in file: ", filename))
  }
  
  return(transect_count)
}

files_to_process <- list.files(path = "/Users/user/Desktop/productivity_extracted/atlantis/", 
                               pattern = "\\.csv$", 
                               full.names = TRUE)

transect_count <- 1

# Extract dive number and file number from filenames and process each file
for (filename in files_to_process) {
  dive_number <- gsub(".*dive([0-9]+).*", "\\1", basename(filename))
  transect_count <- process_file(filename, dive_number, transect_count)
}


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
  cbind(Transect = transect_info, Richness = richness, Abundance = abundance,env_averages)
}

# Directory containing transect files
transect_directory <- "/Users/user/Desktop/productivity_extracted/atlantis/atlantis_50m_transects"
# Update with your directory path

transect_files <- list.files(transect_directory, full.names = TRUE)
transect_data <- lapply(transect_files, process_transect)

atlantis_transect_summary <- do.call(rbind, transect_data)
print(atlantis_transect_summary)

# add a fishing impact column 

atlantis_transect_summary$LostFishingGear<- NA
atlantis_transect_summary$SAI_Evidence<- NA
atlantis_transect_summary$LostFishingGear <- rep('N', nrow(atlantis_transect_summary))
atlantis_transect_summary$SAI_Evidence <- rep('N', nrow(atlantis_transect_summary))

atlantis_transect_summary$LostFishingGear[atlantis_transect_summary$Transect == 'dive15_transect26.csv'] <- 'Y' # rope 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect1.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect7.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect2.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect3.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect4.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect5.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect6.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect8.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive16transect9.csv'] <- 'Y' # trawl marks 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive15transect8.csv'] <- 'Y' # rubble
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive15transect31.csv'] <- 'Y' # rubble and urchin spines 
atlantis_transect_summary$SAI_Evidence[atlantis_transect_summary$Transect == 'dive15transect16.csv'] <- 'Y' # rubble and urchin spines 


atlantis_transect_summary$Seamount <- 'Atlantis'

# removing transects that contain no data 


# export dataframe to a csv 
write.csv(atlantis_transect_summary, "/Users/user/Desktop/metadata_flow/SEAMOUNT_TRANSECTS/atlantis_transect_summary.csv", row.names=FALSE)

ggplot(atlantis_transect_summary, aes(x = AverageDepth, y = Richness)) +
  geom_point() +
  theme_minimal() +
  labs(title = "Species Richness vs Depth",
       x = "Average Depth (m)",
       y = "Species Richness")



# check for normality 

qqnorm(transect_summary$AverageGradient)
qqline(transect_summary$Richness)
shapiro.test(transect_summary$Richness)


