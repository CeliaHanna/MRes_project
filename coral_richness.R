# calculating richness of coral transects 

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
transect_directory <- "/Users/user/Desktop/metadata_flow/coral_50m_transects"  # Update with your directory path

transect_files <- list.files(transect_directory, full.names = TRUE)
transect_data <- lapply(transect_files, process_transect)

coral_transect_summary <- do.call(rbind, transect_data)
print(coral_transect_summary)


class(coral_transect_summary)



# add a fishing impact column 

coral_transect_summary$FishingImpact <- NA
print(transect_summary)

coral_transect_summary$FishingImpact <- rep('N', nrow(coral_transect_summary))
coral_transect_summary$FishingImpact[coral_transect_summary$Transect == 'dive4transect1.csv'] <- 'Y'

ta# removing transects that contain no data 

coral_transect_summary <- coral_transect_summary[-c(27, 74, 75, 79), ]


# export dataframe to a csv 
write.csv(coral_transect_summary, "/Users/user/Desktop/metadata_flow/SEAMOUNT_TRANSECTS/coral_transect_summary.csv", row.names=FALSE)


ggplot(transect_summary, aes(x = AverageDepth, y = Richness)) +
  geom_point() +
  theme_minimal() +
  labs(title = "Species Richness vs Depth",
       x = "Average Depth (m)",
       y = "Species Richness")


ggplot(transect_summary, aes(x = AverageGradient, y = Richness)) +
  geom_point() +
  theme_minimal() +
  labs(title = "Species Richness vs Gradient",
       x = "Average Gradient (m)",
       y = "Species Richness")


# check for normality 

qqnorm(transect_summary$AverageGradient)
qqline(transect_summary$Richness)
shapiro.test(transect_summary$Richness)

transect_summary
