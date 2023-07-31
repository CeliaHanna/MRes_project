import pandas as pd

# Read the first CSV file containing coordinates and other columns
first_csv = pd.read_csv('/Users/user/Desktop/metadata_flow/4.+TSPD/MOW.csv')

# Read the second CSV file containing coordinates and slope information
second_csv = pd.read_csv('/Users/user/Desktop/gradient_info/dive13slopes.csv')

# Round the 'latitude' and 'longitude' columns to 6 decimal places in both DataFrames
first_csv['lat'] = first_csv['lat'].round(6)
first_csv['lon'] = first_csv['lon'].round(6)

second_csv['lat'] = second_csv['lat'].round(6)
second_csv['lon'] = second_csv['lon'].round(6)

# Merge the two DataFrames based on shared coordinates
merged_df = first_csv.merge(second_csv, on=['lat', 'lon'], how='left')

# # Rename the slope column to something meaningful if needed
merged_df.rename(columns={'Slope': 'slope_value'}, inplace=True)

# # Save the merged DataFrame back to a new CSV file
merged_df.to_csv('~/Desktop/metadata_flow/5.+GRADIENT/MOW.csv', index=False)