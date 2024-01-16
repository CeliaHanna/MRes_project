# Assume your data frame is called 'data' and it contains the columns 'seamount' and 'richness'.

# Fit a Poisson model
poisson_model <- glm(log_richness ~ Seamount, data =even_rows, family = "poisson")

# Calculate the ratio of residual deviance to degrees of freedom
overdispersion_ratio <- sum(residuals(poisson_model, type = "pearson")^2) / poisson_model$df.residual

# Output the ratio
overdispersion_ratio

# If the overdispersion_ratio is significantly greater than 1, it suggests overdispersion.



