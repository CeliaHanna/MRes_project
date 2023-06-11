import rasterio
import matplotlib.pyplot as plt
from rasterio.plot import show
from matplotlib.colors import ListedColormap
from matplotlib.ticker import MultipleLocator
import matplotlib.colors as colors

# Load the raster map
intromap = rasterio.open('/Users/user/Desktop/gebco_2023_n-10.385_s-51.8176_w27.6576_e69.4129.tif')

# Define the colors for land (higher elevations) and deep ocean (lower elevations)
colors_ocean = ['#2F9E2E', '#9FFFB1']  # Shades of green
colors_land = ['#0000FF', '#0066FF', '#00B2FF']  # Shades of blue

# Combine the colors for land and ocean
colors_combined = colors_land + colors_ocean

# Create a custom color gradient
color_gradient = colors.LinearSegmentedColormap.from_list('custom_gradient', colors_combined, N=256)

# Plot the raster map with the custom color gradient
fig, ax = plt.subplots()
show(intromap, cmap=color_gradient, ax=ax)

# Add latitude-longitude coordinate labels
ax.set_xlabel('Longitude')
ax.set_ylabel('Latitude')

# Get the geospatial transformation information
transform = intromap.transform

# Get the raster's corner coordinates
top_left = transform * (0, 0)
bottom_right = transform * (intromap.width, intromap.height)

# Extract the latitude and longitude values
latitudes = [top_left[1], bottom_right[1]]
longitudes = [top_left[0], bottom_right[0]]

# Customize the tick labels with latitude-longitude coordinates
ax.set_xticks(longitudes)
ax.set_yticks(latitudes)

# Increase the number of grid values on the axis
ax.xaxis.set_major_locator(MultipleLocator(5))
ax.yaxis.set_major_locator(MultipleLocator(5))

plt.tight_layout()

plt.savefig('SWIRR.png')
# Show the plot

