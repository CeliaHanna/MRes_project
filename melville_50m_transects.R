
setwd("/Users/user/Desktop/metadata_flow/melville_interpolated")


# Function to cut up the route into 50m transects and save them
process_file <- function(filename, dive_number) {
  data <- read.csv(filename)
  data$transect <- cut(data$cumulative_distance, 
                       breaks=seq(0, max(data$cumulative_distance), by=50), 
                       include.lowest=TRUE, 
                       labels=FALSE)
  list_of_transects <- split(data, data$transect)
  
  save_path <- "/Users/user/Desktop/metadata_flow/melville_50m_transects" # specify your desired path here
  
  for (i in seq_along(list_of_transects)) {
    transect_name <- paste0("dive", dive_number, "transect", i, ".csv")
    write.csv(list_of_transects[[i]], file = transect_name, row.names = FALSE)
  }
}

files_to_process <- list.files(path = "/Users/user/Desktop/metadata_flow/melville_interpolated", 
                               pattern = "\\.csv$", 
                               full.names = TRUE)


# Extract dive number from filenames and process each file
for (filename in files_to_process) {
  dive_number <- gsub(".*dive([0-9]+).*", "\\1", basename(filename))
  process_file(filename, dive_number)
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
  env_averages <- calculate_environmental_averages(data)
  
  transect_info <- basename(file_path)  # Extract transect information
  
  # Combine richness and environmental averages
  cbind(Transect = transect_info, Richness = richness, env_averages)
}

# Directory containing transect files
transect_directory <- "/Users/user/Desktop/metadata_flow/melville_50m_transects"
# Update with your directory path

transect_files <- list.files(transect_directory, full.names = TRUE)
transect_data <- lapply(transect_files, process_transect)

melville_transect_summary <- do.call(rbind, transect_data)
print(melville_transect_summary)




# STOP HERE FOR LUNCH 


# add a fishing impact column 

melville_transect_summary$FishingImpact <- NA

melville_transect_summary$FishingImpact <- rep('N', nrow(melville_transect_summary))


melville_transect_summary$FishingImpact[melville_transect_summary$Transect == 'divemerged_DIVE8_interpolated.csvtransect20.csv'] <- 'Y'
melville_transect_summary$FishingImpact[melville_transect_summary$Transect == "divemerged_DIVE8_interpolated.csvtransect29.csv"] <- 'Y' 
melville_transect_summary$FishingImpact[melville_transect_summary$Transect == "divemerged_DIVE8_interpolated.csvtransect30.csv"] <- 'Y' 
melville_transect_summary$FishingImpact[melville_transect_summary$Transect == "divemerged_DIVE8_interpolated.csvtransect36.csv"] <- 'Y' 
melville_transect_summary$FishingImpact[melville_transect_summary$Transect == "divemerged_DIVE9_interpolated.csvtransect1.csv"] <- 'Y' 
melville_transect_summary$FishingImpact[melville_transect_summary$Transect == "divemerged_DIVE9_interpolated.csvtransect9" ] <- 'Y' 
melville_transect_summary$FishingImpact[melville_transect_summary$Transect == "divemerged_DIVE9_interpolated.csvtransect2.csv"] <- 'Y' 
melville_transect_summary$FishingImpact[melville_transect_summary$Transect == "divemerged_DIVE9_interpolated.csvtransect3"] <- 'Y'



View(melville_transect_summary)

# removing transects that contain no data 

melville_transect_summary <- subset(melville_transect_summary, MostCommonSubstrate != "Unknown")


# export dataframe to a csv 
write.csv(melville_transect_summary, "/Users/user/Desktop/metadata_flow/SEAMOUNT_TRANSECTS/melville_transect_summary.csv", row.names=FALSE)

ggplot(melville_transect_summary, aes(x = AverageDepth, y = Richness)) +
  geom_point() +
  theme_minimal() +
  labs(title = "Species Richness vs Depth",
       x = "Average Depth (m)",
       y = "Species Richness")



# check for normality 

qqnorm(transect_summary$AverageGradient)
qqline(transect_summary$Richness)
shapiro.test(transect_summary$Richness)

melville_transect_summary
