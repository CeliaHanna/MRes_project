import pandas as pd
import numpy as np
import utm
import matplotlib.pyplot as plt

# Define the calc_distance function
def calc_distance(start, end):
    start_x, start_y, _, _ = utm.from_latlon(start[0], start[1])
    end_x, end_y, _, _ = utm.from_latlon(end[0], end[1])
    dif_x = start_x - end_x
    dif_y = start_y - end_y
    distance = np.sqrt(dif_x ** 2 + dif_y ** 2)
    return distance

file_paths = [
    '/Users/user/Desktop/metadata_flow/sorted_metadata_files+substratecopy/merged+sorteddive1.csv',
    '/Users/user/Desktop/metadata_flow/sorted_metadata_files+substratecopy/merged+sorteddive2.csv',
    '/Users/user/Desktop/metadata_flow/sorted_metadata_files+substratecopy/merged+sorteddive3.csv',
    '/Users/user/Desktop/metadata_flow/sorted_metadata_files+substratecopy/merged+sorted-dive4-file2.csv',
    '/Users/user/Desktop/metadata_flow/sorted_metadata_files+substratecopy/merged+sorteddive5.csv']
    

# Calculate the number of rows and columns based on the number of files
num_files = len(file_paths)
num_rows = num_files // 2  # Divide by 2 for rows
num_cols = 2  # Always have 2 columns

# Create subplots
fig, axes = plt.subplots(nrows=num_rows, ncols=num_cols, figsize=(15, 10))

# Loop through each file path and populate the subplots
for (ax, file_path) in zip(axes.flatten(), file_paths):
    data_frame = pd.read_csv(file_path)
    depth = data_frame['ROV.RovDepth'].to_numpy()

    lat_data = data_frame['lat'].to_numpy()
    long_data = data_frame['lon'].to_numpy()

    start = [lat_data[0], long_data[0]]

    depth_diff = np.abs(depth[:-1] - depth[1:])
    inds = np.where(depth_diff >= 4)[0]

    total_distance = 0
    distances = [0]
    if not len(inds):
        end = [lat_data[-1], long_data[-1]]
        distances.append(calc_distance(start,end))
        inds = [0,-1]

    else:
        for idx in inds:
            end = [lat_data[idx], long_data[idx]]
            distance = calc_distance(start, end)
            total_distance += distance
            distances.append(total_distance)
            start = [lat_data[idx + 1], long_data[idx + 1]]

        distances = distances[:-1]


    # Populate each subplot with data and set the custom title
    ax.plot(distances, depth[inds], marker='o', linestyle='-')
    ax.set_xlabel('Total Distance (in meters)')
    ax.set_ylabel('Depth')
    ax.invert_yaxis()
    ax.set_ylim(1600, 400)
    ax.set_xlim(0,500)

    # Extract the filename from the path and use it as the title
    title = file_path.split('/')[-1]
    ax.set_title(title)
    ax.grid(True)

# Adjust layout and display the plot
plt.tight_layout()
plt.show()

# Save the figure to a file
plt.savefig('/Users/user/Desktop/metadata_flow/sorted_metadata_files+substratecopy/coraltransectsmerged.png')  # Change the file name and format as needed



