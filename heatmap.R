library(vegan)

# Assuming 'your_data' is your original data frame where rows are sites and columns are species
# Transpose the data
transposed_data <- t(species_abundance_df)

class(transposed_data)

# Convert to presence/absence (1/0)
presence_absence_data <- as.data.frame((transposed_data > 0)*1)

# Plot species accumulation curves for each site
par(mfrow=c(2, 2)) # Adjust layout based on the number of sites (e.g., 2x2 for 4 sites)
for (site in colnames(presence_absence_data)) {
  # Extract data for the site
  site_data <- presence_absence_data[, site, drop = FALSE]
  
  # Perform species accumulation
  spec_accum <- specaccum(site_data, method = "exact")
  
  # Plot
  plot(spec_accum, main=paste("Species Accumulation for", site))
}

# Load necessary libraries
library(ggplot2)
library(reshape2)
library(dplyr)
# Assuming 'your_matrix' is your original data frame where rows are seamounts and columns are species
# Convert your matrix to a data frame if it's not already
data <- as.data.frame(transposed_data)
data$Seamount <- rownames(data) # Convert row names to a column
data
# Transform the data to a long format
long_data <- melt(data, id.vars = "Seamount", variable.name = "Species", value.name = "Abundance")

# Convert Abundance to numeric if it's not already
long_data$Abundance <- as.numeric(long_data$Abundance)

long_data <- long_data[-84, ]


names(long_data)[1] <- "Morphospecies"
names(long_data)[2] <- "Seamount"

long_data <- long_data[!grepl("Seamount", long_data$Morphospecies), ]


long_data <- long_data %>%
  mutate(Seamount = case_when(
    Seamount == "V1" ~ "Atlantis",
    Seamount == "coral" ~ "Coral",
    Seamount == "V3" ~ "Melville Bank",
    Seamount == "sapmer" ~ "Sapmer",
    TRUE ~ Seamount  # If none of the conditions match, keep the original value
  ))



# change order of seamounts for heatmap 

# Define the desired order of levels
desired_order <- c("Atlantis", "Sapmer", "Melville Bank", "Coral")

# Convert 'Seamount' to a factor with the desired order
long_data$Seamount <- factor(long_data$Seamount, levels = desired_order)



# Create the heatmap
ggplot(long_data, aes(x = Seamount, y = Morphospecies, fill = Abundance)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12), 
        axis.text.y = element_text(angle = 45, hjust = 1, size = 5)) +
  labs(fill = "Abundance")

