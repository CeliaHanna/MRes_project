# sample 15 transects 

# Set the seed for reproducibility (optional)
set.seed(123)

# Number of transects to select for each seamount
n_transects_per_seamount <- 15

# List to store sampled dataframes
sampled_dataframes <- list()

# Unique seamounts in the original dataframe
unique_seamounts <- unique(all_transects$Seamount)

# Loop through each seamount
for (Seamount in unique_seamounts) {
  # Subset the original dataframe for the current seamount
  subset_data <- subset(all_transects, Seamount == Seamount)
  
  # Check if there are at least 15 transects for the current seamount
  if (nrow(subset_data) >= n_transects_per_seamount) {
    # Randomly sample 15 transects without replacement
    sampled_subset <- subset_data[sample(nrow(subset_data), n_transects_per_seamount), ]
    
    # Append the sampled subset to the list
    sampled_dataframes[[Seamount]] <- sampled_subset
  } else {
    # If there are fewer than 15 transects, you can choose to handle it accordingly
    # For example, you can skip this seamount or include all available transects.
  }
}

# Combine all sampled dataframes into one
fifteen_transects_per_seamount <- do.call(rbind, sampled_dataframes)

# Reset row names of the new dataframe
rownames(sampled_data) <- NULL

# View the resulting sampled_data dataframe
head(sampled_data)
nrow(sampled_data)


# push balanced sampling design through model 

neg_binomial_glmm <- glmer.nb(Richness ~ Seamount + (1|Dive) + (1|AverageDepth),
                              data = sampled_data)


neg_binomial_glmm <- glmer.nb(Abundance ~ Seamount + (1|Dive) + (1|AverageDepth),
                              data = sampled_data)
