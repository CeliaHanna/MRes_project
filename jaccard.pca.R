library(vegan)
library(ggplot2)
library(dplyr)
library(tidyr)


# making species abundance matrices for mesopelagic transects

melville_m <- read.csv("/Users/user/Desktop/metadata_flow/mesopelagic_transects/melville_mesopelagic_transects.csv")
atlantis_m <- read.csv("/Users/user/Desktop/metadata_flow/mesopelagic_transects/atlantis_mesopelagic_transects.csv")
coral_m <- read.csv("/Users/user/Desktop/metadata_flow/mesopelagic_transects/coral_mesopelagic_transects.csv")
sapmer_m <- read.csv("/Users/user/Desktop/metadata_flow/mesopelagic_transects/sapmer_mesopelagic_transects.csv")

# add seamount names 

melville_m$Seamount <- "Melville"
atlantis_m$Seamount <- "Atlantis"
coral_m$Seamount <- "Coral"
sapmer_m$Seamount <- "Sapmer"

sapmer_new <- 

sapmer_filtered <- subset(sapmer_m, depth >= 500)
melville_filtered <- subset(melville_m, depth >=500)
coral_filtered <- subset(coral_m, depth >=500)

melville_filtered<- melville_filtered[, !colnames(melville_filtered) == "Substrate"]
melville_filtered$transect <- NA

# coral is playing up, remove data from deeper than 800m

# Assuming your DataFrame is called 'df'
coral_m<- subset(coral_m, depth <= 800)

specaccum(species_abundance_df)

# compare depths 

boxplot(melville_m$depth, atlantis_m$depth, coral_m$depth, sapmer_m$depth,
        names = c("Melville Bank", "Atlantis", "Coral","Sapmer"),
        main = "Comparison of Depth Distributions",
        xlab = "Seamount",
        ylab = "Depth (m)",
        ylim = c(400,900))
v

axis(2, at = seq(0, 1000, by = 100), labels = rev(seq(0, 1000, by = 100)))


ggplot(combined_data, aes(x = Seamount, y = depth)) + 
  geom_violin(trim = FALSE) +
  labs(title = "Comparison of Depth Distributions",
       x = "Seamount",
       y = "Depth (m)") +
  ylim(400, 900)


mean_melville <- mean(melville_m$depth)
mean_melville <- mean(atlantis_m$depth)
mean_coral <- mean(coral_m$depth)
mean_sapmer <- mean(sapmer_m$depth)


plot(mean_melville, mean_melville, mean_coral, mean_sapmer,
        names = c("Melville", "Atlantis", "Coral","Sapmer"),
        main = "Comparison of Depth Distributions",
        xlab = "Seamount",
        ylab = "Depth", 
        ylim = c(500,1000))
                    

# combine all the data 

combined_data <- rbind(melville_m, atlantis_m, coral_m, sapmer_m)

combined_data_filtered <- rbind(melville_filtered, atlantis_m, coral_filtered, sapmer_filtered)

# filter for VME taxa only 

filtered_df <- combined_data_filtered[grepl("Cnidaria", combined_data$label_hierarchy) | grepl("Porifera", combined_data$label_hierarchy) | grepl("Bryozoa", combined_data$label_hierarchy) | grepl("Stalked crinoids", combined_data$label_hierarchy), ]

# create species abundance matrix 

# Aggregate data
aggregated_data <- filtered_df %>%
  group_by(Seamount, label_name) %>%
  summarize(abundance = n(), .groups = 'drop')

# Spread the data to wide format
species_abundance_df <- aggregated_data %>%
  spread(key = label_name, value = abundance, fill = 0)

# first row: Atlantis
# second row: coral 
# third row: melville
# fourth row: Sapmer

species_abundance_df<- as.data.frame(species_abundance_df)
species_abundance_df<- as.matrix(species_abundance_df)

species_abundance_df<-species_abundance_df[,-1]
species_abundance_df<- as.data.frame(species_abundance_df)


# Atlantis      Coral       Melville Bank          Sapmer 
#   31            28                13               13 


# convert character colummns to numeric 

species_abundance_numeric <- species_abundance_df
for (i in seq_along(species_abundance_numeric)) {
  species_abundance_numeric[[i]] <- as.numeric(as.character(species_abundance_numeric[[i]]))
}

# converting to a jaccard matrix 

presence_absence_matrix <-species_abundance_numeric  > 0
jaccard_distance <- vegdist(presence_absence_matrix, method = "jaccard")
jaccard_distance
plot(jaccard_distance)

# Plotting PCoA


# Define community labels
community_labels <- c("Atlantis", "Coral", "Melville Bank", "Sapmer")  # Adjust to your data

# Manual color assignment
colors <- c("red", "blue", "green", "black")  # One color per community

# Perform PCoA
pcoa <- cmdscale(jaccard_distance, eig=TRUE, k=2)

par(mar=c(5, 5, 5, 7) + 0.1) 

# Plotting PCoA with colored points
plot(pcoa$points[,1], pcoa$points[,2], 
     col=colors[as.factor(community_labels)],
     xlab="PCoA 1", ylab="PCoA 2", 
     pch=19,  
     cex = 2, # Solid circle
     main="Principal Coordinates Analysis (PCoA) with Jaccard Index")

text(pcoa$points[1,1], pcoa$points[1,2], labels = community_labels[1], pos=2, cex = 1.5)
text(pcoa$points[2,1], pcoa$points[2,2], labels = community_labels[2], pos=2, cex = 1.5)
text(pcoa$points[3,1], pcoa$points[3,2], labels = community_labels[3], pos=4, cex = 1.5)
text(pcoa$points[4,1], pcoa$points[4,2], labels = community_labels[4], pos=4, cex = 1.5)




# seeing which species are shared between melville and sapmer 

common_species <- rownames(presence_absence_matrix )[apply(presence_absence_matrix , 1, function(x) all(x == 1))]

