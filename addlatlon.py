import pandas as pd
import datetime as dt
import numpy as np

# Load Biigle output report into a Pandas DataFrame
biigle_df = pd.read_csv('~/Desktop/metadata_flow/1.TIMESTAMPED/reportdive7file3.csv')

# Extract the capture times from the 'capture_time' column
capture_times = biigle_df['capture_time']

# Load the other CSV containing times and lat/long coordinates
other_df = pd.read_csv('~/Desktop/trimmed_metafiles2/dive8meta2.csv')
other_df = other_df.rename(columns = {'UTC_time' : 'capture_time'})
# Convert the 'capture_time' column in other_df to a datetime object with %H:%M:%S format
other_df['capture_time'] = pd.to_datetime(other_df['capture_time'], format='%H:%M:%S').dt.time

# Create empty lists to store the matched latitudes and longitudes
latitudes = []
longitudes = []
depth = []

# Iterate over each capture time in biigle_df
for capture_time in capture_times:
    # Convert the capture time to a datetime object with dummy date and %H:%M:%S format
    capture_time_dt = dt.datetime.strptime(capture_time, '%Y-%m-%d %H:%M:%S').time()
    dummy_date = dt.datetime(1900, 1, 1)
    capture_datetime = dt.datetime.combine(dummy_date, capture_time_dt)
    
    # Find the closest time in the other DataFrame
    time_diffs = np.abs(other_df['capture_time'].apply(lambda x: dt.datetime.combine(dummy_date, x)) - capture_datetime)
    closest_time_index = np.argmin(time_diffs)
    
    # Extract the corresponding lat/long coordinates and append to the lists
    latitudes.append(other_df.loc[closest_time_index, 'lat'])
    longitudes.append(other_df.loc[closest_time_index, 'lon'])
    depth.append(other_df.loc[closest_time_index, 'depth'])

# Add the latitudes and longitudes as columns to the Biigle output report DataFrame
biigle_df['lat'] = latitudes
biigle_df['lon'] = longitudes
biigle_df['depth'] = depth

# Save the updated DataFrame to a CSV file
biigle_df.to_csv('~/Desktop/metadata_flow/2.+LATLON/reportD7F3.csv', index=False)
