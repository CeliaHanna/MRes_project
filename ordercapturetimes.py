import os
import pandas as pd

import os
import pandas as pd

# Directory containing CSV files
input_directory = '/Users/user/Desktop/metadata_flow/completed_metadata_files'

# Output directory for sorted CSV files
output_directory = '/Users/user/Desktop/metadata_flow/sorted_metadata_files'

# Create the output directory if it doesn't exist
os.makedirs(output_directory, exist_ok=True)

# Get a list of all CSV files in the input directory
csv_files = [file for file in os.listdir(input_directory) if file.endswith('.csv')]

for csv_file in csv_files:
    input_csv = os.path.join(input_directory, csv_file)
    output_csv = os.path.join(output_directory, csv_file)

    # Load the CSV data into a DataFrame
    data_frame = pd.read_csv(input_csv)

    # Sort the DataFrame by the "capture time" column
    sorted_data_frame = data_frame.sort_values(by='capture_time')

    # Write the sorted data to a new CSV file
    sorted_data_frame.to_csv(output_csv, index=False)

    print(f"Sorted data from '{csv_file}' has been saved to '{output_csv}'")
