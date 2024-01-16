library(readr)

# go throguh transects and select those in the depth zone of interest 
# should be this many for each seamount 


# Atlantis      Coral       Melville Bank          Sapmer 
#   31            28                13               13 

# Specify the directory containing the CSV transect files
directory_path <- "/Users/user/Desktop/metadata_flow/SAPMER/sapmer_50m_transects"

# List all CSV files in the directory
csv_files <- list.files(directory_path, pattern = "\\.csv$", full.names = TRUE)

# set maximum number of transects 
max_files <- 32

# Name of the file to store the duplicated data
output_file <- "/Users/user/Desktop/metadata_flow/mesopelagic_transects/thirty_sapmer_mesopelagic_transects.csv"

# Function to read, check, and append each CSV file
process_file <- function(file_path) {
  # Read the CSV file
  df <- read_csv(file_path)
  n
  # Check if any rows have 'depth' between
  if (any(df$depth >= 500 & df$depth <= 800)) {
    # Append the file content to the output file
    if (!file.exists(output_file)) {
      write_csv(df, output_file)
    } else {
      write_csv(df, output_file, append = TRUE)
    }
  }
}

# Apply the function to each file
lapply(csv_files, process_file)


# now count how many transects from each seamount are at depths 600-800m 

# Specify the directory containing the CSV files
directory_path <- "/Users/user/Desktop/metadata_flow/ATLANTIS/atlantis_50m_transects"

# List all CSV files in the directory
csv_files <- list.files(directory_path, pattern = "\\.csv$", full.names = TRUE)

# Initialize a counter
files_with_depth_in_range <- 0

# Function to check each CSV file
check_file_for_depth <- function(file_path) {
  # Read the CSV file
  df <- read_csv(file_path)
  
  # Check if any rows have 'depth' between 500 and 1000
  if (any(df$depth >= 500 & df$depth <= 800)) {
    files_with_depth_in_range <<- files_with_depth_in_range + 1
  }
}

# Apply the function to each file
lapply(csv_files, check_file_for_depth)

# Print the count
print(files_with_depth_in_range)


# coral has 30 
# melville 22 
# sapmer has 44
# atlantis has 31 

specaccum_obj = specaccum(species_abundance_numeric)
plot(specaccum_obj)

richness_estimates = estimateR(species_abundance_numeric)
print(richness_estimates)



plot(s)
