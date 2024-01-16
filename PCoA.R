# Rarefaction and iterating Jaccard pcoa process

library(vegan)

# Define the number of iterations and minimum sample size
n_iterations <- 100
min_samples <- 300

# Function to perform rarefaction and calculate Jaccard Index
rarefaction_analysis <- function(species_abundance_numeric, min_samples) {
  # Apply the function to each row (each seamount)
  rarefied_matrix <- t(apply(species_abundance_numeric, 1, function(row) {
    # Ensure that we are sampling individual occurrences, not summed abundances
    species_indices <- rep(1:length(row), times=row)
    sampled_indices <- sample(species_indices, min_samples)
    sampled_abundance <- table(sampled_indices)
    
    # Convert the table to a numeric vector with the same length as the number of species
    full_sample <- numeric(length(row))
    names(full_sample) <- 1:length(row)
    full_sample[as.character(sampled_indices)] <- as.numeric(sampled_abundance)
    
    return(full_sample)
  }))
  
  # Convert to presence/absence
  presence_absence <- rarefied_matrix > 0
  
  # Calculate Jaccard Index
  jaccard_dist <- vegdist(presence_absence, method="jaccard")
  
  return(jaccard_dist)
}


# Store results from each iteration
all_jaccard_indices <- vector("list", n_iterations)

for(i in 1:n_iterations) {
  all_jaccard_indices[[i]] <- rarefaction_analysis(species_abundance_numeric, min_samples)
}



# Perform PCoA for each iteration
pcoa_results <- lapply(all_jaccard_indices, function(dist) {
  cmdscale(dist, eig=TRUE, k=2)  # Assuming 2D PCoA
})

# You can also average the PCoA results if needed


# Example: Plotting the first two dimensions of the first iteration's PCoA result
plot(pcoa_results[[1]][,1], pcoa_results[[1]][,2], xlab="PCoA 1", ylab="PCoA 2", main="PCoA of Seamounts")


# Plot the first two dimensions of the first PCoA result
plot(pcoa_results[[1]]$points[,1], pcoa_results[[1]]$points[,2], 
     xlab="PCoA 1", ylab="PCoA 2", main="PCoA of Seamounts")

# Add labels

seamount_names <- c("Atlantis","Coral", "Melville Bank", "Sapmer" )
  
text(pcoa_results[[1]]$points[,1], pcoa_results[[1]]$points[,2], 
     labels = seamount_names, pos=4, cex=0.7)  # 'pos=4' places the text to the right of the point



# Average the PcoA results 

# Number of seamounts (assuming it's equal to the number of rows in your original matrix)
num_seamounts <- nrow(species_abundance_numeric)

# Initialize a matrix to store the averaged coordinates
average_pcoa <- matrix(0, nrow=num_seamounts, ncol=2)  # Assuming 2D PCoA

# Summing up all the coordinates from each iteration
for (result in pcoa_results) {
  average_pcoa <- average_pcoa + result$points[, 1:2]
}

# Dividing by the number of iterations to get the average
average_pcoa <- average_pcoa / length(pcoa_results)

# Plot the averaged PCoA results
plot(average_pcoa[,1], average_pcoa[,2], 
     xlab="Average PCoA 1", ylab="Average PCoA 2", main="Average PCoA of Seamounts",
     pch=19, cex=0.5)

# Add labels
text(average_pcoa[,1], average_pcoa[,2], 
     labels = seamount_names, pos=4, cex=0.7)


library(ggplot2)
library(ellipse)

# ... [your existing code] ...

# Calculate standard deviation for each coordinate
std_dev_pcoa <- matrix(0, nrow=num_seamounts, ncol=2)  # Initialize matrix for standard deviation

for (j in 1:num_seamounts) {
  coords_j <- sapply(pcoa_results, function(result) result$points[j, 1:2])
  std_dev_pcoa[j, ] <- apply(coords_j, 1, sd)  # Calculate standard deviation for each seamount
}

# Calculate a size factor for plotting (you may need to adjust this scaling)
size_factor <- rowSums(std_dev_pcoa) * 5  # Adjust multiplier as needed for visibility

# Plot the averaged PCoA results with point size representing the SD
plot(average_pcoa[,1], average_pcoa[,2], 
     xlab="Average PCoA 1", ylab="Average PCoA 2", main="Average PCoA of Seamounts",
     pch=19, cex=size_factor)  # 'cex' controls the size of the points

# Add labels
text(average_pcoa[,1], average_pcoa[,2], 
     labels = seamount_names, pos=4, cex=0.7)

