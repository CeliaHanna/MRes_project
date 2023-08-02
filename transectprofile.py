import pandas as pd
import numpy as np
import utm
import matplotlib.pyplot as plt

file_path = '~/Desktop/metadata_flow/4.+TSPD/testdistance.csv'
data_frame = pd.read_csv(file_path)
depth = data_frame['ROV.RovDepth']
depth = depth.to_numpy()

lat_data = data_frame['lat'].to_numpy()
long_data = data_frame['lon'].to_numpy()

depth_diff = np.abs(depth[:-1] - depth[1:])
inds = np.where(depth_diff >= 4)[0]
print(inds)
print(depth[inds])

def calc_distance(start, end):
    start_x, start_y, _, _ = utm.from_latlon(start[0], start[1])
    end_x, end_y, _, _ = utm.from_latlon(end[0], end[1])
    dif_x = start_x - end_x
    dif_y = start_y - end_y
    distance = np.sqrt(dif_x ** 2 + dif_y ** 2)
    return distance

# Calculate the total distance and store distances in a list
start = [lat_data[0], long_data[0]]
total_distance = 0
distances = [0]  # Initialize with 0 to account for starting point
for idx in inds:
    end = [lat_data[idx], long_data[idx]]
    distance = calc_distance(start, end)
    total_distance += distance
    distances.append(total_distance)  # Store the cumulative distance at each depth point
    start = [lat_data[idx + 1], long_data[idx + 1]]

# Remove the last element in 'distances' to match the dimensions with 'depth[inds]'
distances = distances[:-1]

# Plotting the final dive profile with flipped axes
plt.figure(figsize=(10, 6))
plt.plot(distances, depth[inds], marker='o', linestyle='-')
plt.xlabel('Total Distance (in meters)')
plt.ylabel('Depth')
plt.title('Coral: Dive 3 file 5')
plt.grid(True)
plt.show()

