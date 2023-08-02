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

    start_x, start_y, _ ,_ = utm.from_latlon(start[0],start[1])
    end_x, end_y, _, _ = utm.from_latlon(end[0], end[1])

    dif_x = start_x - end_x
    dif_y = start_y - end_y
    distance = np.sqrt(dif_x **2 + dif_y**2)

    return distance

start = [lat_data[0], long_data[0]]
total_distance = 0
for idx in inds:
    end = [lat_data[idx], long_data[idx]]
    distance = calc_distance(start, end)
    total_distance += distance
    start = [lat_data[idx+1], long_data[idx+1]]

print(total_distance)

# breakpoint()
# import matplotlib.pyplot as plt

# plt.hist(depth_diff)
# plt.show()
