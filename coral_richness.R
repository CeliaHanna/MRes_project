# calculating richness of coral transects 

library(vegan)
library(ggplot2)

getwd()

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
transect_directory <- "/Users/user/Desktop/metadata_flow/CORAL/coral_50m_transects"  # Update with your directory path

transect_files <- list.files(transect_directory, full.names = TRUE)
transect_data <- lapply(transect_files, process_transect)

coral_transect_summary <- do.call(rbind, transect_data)
print(coral_transect_summary)


class(coral_transect_summary)



# add a fishing impact column 

coral_transect_summary$LostFishingGear <- NA
coral_transect_summary$SAI_Evidence <- NA

coral_transect_summary$LostFishingGear <- rep('N', nrow(coral_transect_summary))
coral_transect_summary$SAI_Evidence<- rep('N', nrow(coral_transect_summary))
coral_transect_summary

coral_transect_summary$LostFishingGear[coral_transect_summary$Transect == 'dive4transect1.csv'] <- 'Y'

coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect1.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect2.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect3.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect4.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect5.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect6.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect7.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect8.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect9.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect10.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect11.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect12.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect13.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect14.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect15.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect16.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect17.csv'] <- 'Y'
coral_transect_summary$SAI_Evidence[coral_transect_summary$Transect == 'dive4transect18.csv'] <- 'Y'


# removing transects that contain no data 

coral_transect_summary <- coral_transect_summary[-c(27, 74, 75, 79), ]

coral_transect_summary$Seamount <- 'Coral'

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


