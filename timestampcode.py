import datetime
import pandas as pd 
import datetime as dt
import numpy as np

# Load biigle output report 
biigle_df = pd.read_csv('/Users/user/Desktop/metadata_flow/biiglereports_raw/11716-dive8-file5.csv')

# Remove square brackets from the 'frames' column and convert to float
biigle_df['frames'] = biigle_df['frames'].str.strip('[]').astype(float)

# Extract the frame durations from the 'frames' column
frame_durations = biigle_df['frames'] 

# # Create a datetime variable of start time
video_start = datetime.datetime(2011, 11, 24, 14, 16, 00)

# # Create a list of datetime objects representing the time each frame was captured
time_list = [video_start + datetime.timedelta(seconds=frame_duration) for frame_duration in frame_durations]

# Format the datetime objects in time_list as '%H:%M:%S' strings
time_strings = [time_obj.strftime('%Y-%m-%d %H:%M:%S') for time_obj in time_list]

# # Convert the list of datetime objects to a Pandas Series
time_series = pd.Series(time_strings) 

# Add a new column to the DataFrame containing the capture times
biigle_df['capture_time'] = time_series

# Save the DataFrame to a new CSV file
biigle_df.to_csv('~/Desktop/metadata_flow/1.TIMESTAMPED/reportdive8file5.csv', index=False)


