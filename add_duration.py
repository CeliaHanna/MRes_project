import pandas as pd

# Function to convert seconds to hours:minutes:seconds format
def convert_to_hours_minutes_seconds(seconds):
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    seconds = seconds % 60
    return f"{int(hours):02d}:{int(minutes):02d}:{int(seconds):02d}"

# Read the CSV file into a DataFrame
csv_file = '~/Desktop/metadata_flow/2.+LATLON/MOW.csv'
df = pd.read_csv(csv_file)

# Apply the conversion function to 'seconds' column and create a new column 'hours_minutes'
df['video_duration'] = df['frames'].apply(convert_to_hours_minutes_seconds)

# Save the updated DataFrame to a new CSV file
output_csv_file = '~/Desktop/metadata_flow/2.+LATLON/MOW.csv'
df.to_csv(output_csv_file, index=False)

print("Conversion completed. New CSV file saved.")
