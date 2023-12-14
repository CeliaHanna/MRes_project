library(dplyr)
library(ggplot2)

# combine all transect data from each seamount into a dataframe 

all_transects <- rbind(melville_transect_summary, 
                       sapmer_transect_summary, 
                       coral_transect_summary, 
                       atlantis_transect_summary)

rownames(all_transects) <- NULL

# adding the dive column 

# Assuming your dataframe is named 'your_dataframe'
all_transects <- all_transects%>%
  mutate(Dive = as.numeric(gsub("^dive([0-9]+).*", "\\1", Transect)))

# adding depth zone information (so it can be later included as a random effect)

# Define the breaks for the depth zones
breaks <- c(0, 200, 400, 600, 800, 1000, 1200, 1400)

# Create the 'depth zone' column using cut()
all_transects$depth_zone <- cut(all_transects$AverageDepth, breaks = breaks, labels = c(1, 2, 3, 4, 5, 6, 7), right = FALSE)


# Select every other row so that each transect is 50m apart 
# creates more independence of sampling units

# Create a new dataframe with even-indexed rows from df
even_rows <- all_transects[seq(2, nrow(all_transects), by = 2), ]

odd_rows_df <- all_transects[seq(2, nrow(all_transects), by = 2), ]

# Example: Print the new dataframe
print(even_rows_df)

par(mfrow = c(1, 2))

# examining distribution of the response variable abundance and richness

hist(even_rows$Richness, main= "", xlab = "Morphospecies Richness")
hist(even_rows$sqrt_richnes, main = "", xlab = "Morphospecies Richness (transformed)")

hist(even_rows$Abundance, main= "", xlab = "VME Morphospecies Abundance")
hist(even_rows$log_abundance, main = "", xlab = "VME Morphospecies Abundance (transformed)")


# now a multivariate regression model to see if these richness and abundance differences between seamounts exist 

model <- lm(sqrt_richness + log_abundance ~Seamount, even_rows)
summary(model)


# create dataframe of model outputs and plot results 

# Create a data frame from the summary table
summary_data_abundance <- data.frame(
  Estimate = c(1.2706, 2.4447, 2.9474,1.5759),
  Std.Error = c(0.2332, 0.2823, 0.3011, 0.3341), 
  Seamount = c("Atlantis", "Coral", "Melville Bank", "Sapmer")
)


summary_data_richness <- data.frame(
  Estimate = c(1.2569, 2.4194, 2.1393, 1.6486), 
  Std.Error = c( 0.2171, 0.2627 , 0.2802 ,  0.3110), 
  Seamount = c("Atlantis", "Coral", "Melville Bank", "Sapmer")
)


# Combine the two data frames
combined_data <- rbind(
  data.frame(Data = "VME Morphospecies Abundance", summary_data_abundance),
  data.frame(Data = "VME Morphospecies Richness", summary_data_richness)
)

# Specify the desired order of Seamounts
combined_data$Seamount <- factor(combined_data$Seamount, levels = c("Atlantis", "Sapmer", "Melville Bank", "Coral"))

# Create the grouped bar chart
ggplot(combined_data, aes(x = Seamount, y = Estimate, fill = Data)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = Estimate - Std.Error, ymax = Estimate + Std.Error), width = 0.2, position = position_dodge(width = 0.7)) +
  labs(x = "Seamount", y = "Estimate", fill = NULL, title = "Comparison of VME Morphospecies Abundance and Richness by Seamount") +  # Add a title here
  theme_minimal() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 11))  # Adjust font size here




# now trying using negative binomial regression 

# Load necessary libraries
library(lme4)
library(MASS)  # For the negative binomial family

# Fit a Negative Binomial GLMM tp look at richness while accounting for random effects 
neg_binomial_glmm <- glmer.nb(Richness ~ Seamount + (1|Dive) + (1|depth_zone),
                              data = even_rows)

# Create a data frame from the summary table
richness_data_binomial <- data.frame(
  Estimate = c(1.0088,1.8981, 1.6937,1.3728),
  Std.Error = c(0.2767, 0.2862, 0.3028, 0.3830), 
  Seamount = c("Atlantis", "Coral", "Melville Bank", "Sapmer")
)
# Fit a Negative Binomial GLMM tp look at abundance while accounting for random effects 

neg_binomial_glmm <- glmer.nb(Abundance ~ Seamount + (1|depth_zone) + (1|Dive),
                              data = even_rows)

abundance_data_binomial <- data.frame(
  Estimate = c(1.8073, 2.7806, 3.1655, 2.9358),
  Std.Error = c(0.3183, 0.2939 , 0.3122,  0.3911),    
  Seamount = c("Atlantis", "Coral", "Melville Bank", "Sapmer")
)


# Combine the two data frames
combined_data_binomial<- rbind(
  data.frame(Data = "VME Morphospecies Abundance", abundance_data_binomial),
  data.frame(Data = "VME Morphospecies Richness",richness_data_binomial)
)

# Specify the desired order of Seamounts
combined_data_binomial$Seamount <- factor(combined_data_binomial$Seamount, levels = c("Atlantis", "Sapmer", "Melville Bank", "Coral"))

# Create the grouped bar chart
ggplot(combined_data_binomial, aes(x = Seamount, y = Estimate, fill = Data)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = Estimate - Std.Error, ymax = Estimate + Std.Error), width = 0.2, position = position_dodge(width = 0.7)) +
  labs(x = "Seamount", y = "Estimate", fill = NULL, title = "VME Morphospecies Abundance and Richness Across Seamounts") +  # Add a title here
  theme_minimal() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 11))  # Adjust font size here



# make a forest plot for ust the binomial richness data 

richness_data_binomial$Seamount <- factor(richness_data_binomial$Seamount, levels = c("Atlantis", "Sapmer", "Melville Bank", "Coral"))


# Create a forest plot
ggplot(richness_data_binomial, aes(x = Estimate, y = Seamount)) +
  geom_point(size = 3) +  # Points for estimates
  geom_errorbarh(aes(xmin = Estimate - 1.96 * Std.Error, xmax = Estimate + 1.96 * Std.Error), height = 0.2) +  # Confidence intervals  # Line at zero
  labs(x = "Richness Estimate", y = NULL, title = "Comparison of VME Morphospecies Richness Estimates Across Seamounts") +  # Y-axis label removed
  theme_minimal() +
  coord_flip()

neg_binomial_glmm <- glmer.nb(Richness~ SAI_Evidence,
                              data = sapmer_transect_summary)

neg_binomial_glmm <- glmer.nb(Richness ~ SAI_Evidence + (1|Dive) + (1|depth_zone),
                              data = all_transects)

neg_binomial_glmm <- glmer.nb(Richness ~ Seamount + (1|SAI_Evidence) + (1|Dive) + (1|depth_zone),
                              data = all_transects)


glm_model <- glm.nb(Richness ~ SAI_Evidence_binary, data = even_rows)



# Assuming your data frame is called 'df'
# Assuming your data frame is called 'df'
all_transects$SAI_Evidence_binary<- ifelse(all_transects$SAI_Evidence == "Y", 1, 0)





# poisson glmm model 

glmm_model <- glmer(Richness~SAI_Evidence + (1|Seamount) + (1|depth_zone), data = all_transects, family = Gamma)

hist(all_transects$Richness)

library(dplyr)

# Group the data by seamount and calculate the proportion of "Y" in each group
result <- all_transects %>%
  group_by(Seamount) %>%
  summarize(Y_proportion = mean(SAI_Evidence == "Y"))

# Find the seamount with the highest Y proportion
seamount_with_highest_Y <- result %>%
  top_n(1, Y_proportion)

# Print the seamount with the highest Y proportion
seamount_with_highest_Y


#
lm <- lm(Richness ~ AverageDepth, data = all_transects)



