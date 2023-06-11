import os
import pandas as pd
import glob

# Directory path containing the CSV files
csv_files_dir = '/Users/user/Desktop/metadata_flow/telemetry/OneDrive_dive9_ALL'

# Get a list of all CSV files in the directory
csv_files = glob.glob(os.path.join(csv_files_dir, '*.csv'))

# List to store the dataframes from each file
dfs = []

# Iterate through all the CSV files in the directory
for file_path in csv_files:
    # Read each CSV file into a dataframe
    df = pd.read_csv(file_path)
    # Append the dataframe to the list
    dfs.append(df)

# Concatenate all dataframes into a single dataframe
merged_df = pd.concat(dfs, ignore_index=True)

# Sort the merged dataframe by the time column
merged_df.sort_values('Timestamp', inplace=True)

# Drop duplicate rows based on all columns
merged_df.drop_duplicates(inplace=True)

# Path to save the merged file
output_file_path = '/Users/user/Desktop/metadata_flow/3.MERGEDTELEMETRIES/merged_ALLdive9.csv'

# Save the merged dataframe to a new CSV file
merged_df.to_csv(output_file_path, index=False)
