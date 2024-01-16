# correlation betweeen temperature and community composition 

# first average all the iterations of the jaccard 
class(all_jaccard_indices)

# average all the matrices 

# Sum all matrices in the list
summed_matrix <- Reduce("+", all_jaccard_indices)

# Calculate the number of matrices
num_matrices <- length(all_jaccard_indices)

# Get the average matrix
average_matrix <- summed_matrix / num_matrices

average_matrix

# now make a temperature matrix 

# Assuming your DataFrame is named 'df' and has columns 'averagetemperature' and 'seamount'

# Step 1: Extract average temperature for each Seamount
# This creates a named vector of average temperatures
average_temperatures <- with(filtered_df, tapply(CTD.Temperature, Seamount, mean))

# Step 2: Calculate absolute differences
# Initialize a matrix to store the temperature differences
n <- length(average_temperatures)
temperature_diff_matrix <- matrix(NA, n, n, 
                                  dimnames = list(names(average_temperatures), 
                                                  names(average_temperatures)))

# Populate the matrix with absolute differences
for (i in 1:(n-1)) {
  for (j in (i+1):n) {
    diff <- abs(average_temperatures[i] - average_temperatures[j])
    temperature_diff_matrix[i, j] <- diff
    temperature_diff_matrix[j, i] <- diff # since the matrix is symmetric
  }
}

# 'temperature_diff_matrix' now contains the absolute differences in temperature



# Assuming 'temperature_diff_matrix' is your temperature difference matrix
# and 'jaccard_matrix' is your Jaccard similarity matrix
# Assuming 'temperature_diff_matrix' is your temperature difference matrix
# and 'average_matrix' is your Jaccard matrix in the format you provided

# Flatten the lower triangular part of the matrices, excluding the diagonal
temp_diff_vector <- temperature_diff_matrix[lower.tri(temperature_diff_matrix)]
jaccard_vector <- average_matrix[lower.tri(average_matrix)]

# Perform a correlation test - let's use Spearman's rank correlation
correlation_test_result <- cor.test(temp_diff_vector, jaccard_vector, method = "pearson")

# Output the result
correlation_test_result

# average salinities 

average_salinities <- with(filtered_df, tapply(CTD.Salinity, Seamount, mean))

# Step 2: Calculate absolute differences
# Initialize a matrix to store the temperature differences
salinity_diff_matrix <- matrix(NA, n, n, 
                                  dimnames = list(names(average_salinities), 
                                                  names(average_salinities)))

# Populate the matrix with absolute differences
for (i in 1:(n-1)) {
  for (j in (i+1):n) {
    diff <- abs(average_salinities[i] - average_salinities[j])
    salinity_diff_matrix[i, j] <- diff
    salinity_diff_matrix[j, i] <- diff # since the matrix is symmetric
  }
}

# Flatten the lower triangular part of the matrices, excluding the diagonal
salinity_diff_vector <- salinity_diff_matrix[lower.tri(salinity_diff_matrix)]
jaccard_vector <- average_matrix[lower.tri(average_matrix)]

# Perform a correlation test - let's use Spearman's rank correlation
correlation_test_result <- cor.test(salinity_diff_vector, jaccard_vector, method = "pearson")

# Output the result
correlation_test_result


library(vegan)

# trying the mantel test 

mantel_result <- mantel(average_matrix, temperature_diff_matrix, method = "pearson")

# View the results
print(mantel_result)


mantel_result2<-  mantel(average_matrix, salinity_diff_matrix, method = "pearson")

print(mantel_result2)
