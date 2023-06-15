import pandas as pd
import matplotlib.pyplot as plt

# List of file paths for the CSV files
file_paths = [
    '/Users/user/Desktop/metadata_flow/Seamount_level_metadata/atlantis.csv',
    '/Users/user/Desktop/metadata_flow/Seamount_level_metadata/MOW.csv',
    '/Users/user/Desktop/metadata_flow/Seamount_level_metadata/sapmer.csv',
    '/Users/user/Desktop/metadata_flow/Seamount_level_metadata/melville.csv',
    '/Users/user/Desktop/metadata_flow/Seamount_level_metadata/coral.csv'
]

# Determine the number of seamounts
num_seamounts = len(file_paths)

# Create a figure and subplots
fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(12, 8))

# Remove the last subplot in the second row (to make it blank)
axes[1, 2].axis('off')

# List of subplot titles
subplot_titles = [
    'Seamount 1: Atlantis Bank',
    'Seamount 2: MOW',
    'Seamount 3: Sapmer',
    'Seamount 4: Melville',
    'Seamount 5: Coral'
]

# Loop through the file paths and plot each subplot
for i, file_path in enumerate(file_paths):
    # Read the CSV file into a DataFrame
    data = pd.read_csv(file_path)

    # Convert 'CTD.Salinity' and 'CTD.Temperature' columns to numeric
    data['CTD.Salinity'] = pd.to_numeric(data['CTD.Salinity'], errors='coerce')
    data['CTD.Temperature'] = pd.to_numeric(data['CTD.Temperature'], errors='coerce')

    # Filter rows with salinity values between 30 and 40, and temperature values between 0 and 20
    filtered_data = data[(data['CTD.Salinity'] >= 30) & (data['CTD.Salinity'] <= 40) & (data['CTD.Temperature'] >= 0) & (data['CTD.Temperature'] <= 20)]

    # Extract the necessary columns
    depth = filtered_data['ROV.RovDepth']
    salinity = filtered_data['CTD.Salinity']
    temperature = filtered_data['CTD.Temperature']

    # Plot the T-S subplot
    ax = axes[i // 3, i % 3]
    ax.plot(salinity, depth, 'b-', label='Salinity')  # Plot salinity vs. depth

    # Create a twin x-axis for temperature
    ax2 = ax.twiny()
    ax2.plot(temperature, depth, 'r-', label='Temperature')  # Plot temperature vs. depth

    # Set the range for each x-axis
    ax.set_xlim(30, 40)
    ax2.set_xlim(0, 20)

    # Set plot labels and title
    ax.set_xlabel('Salinity')
    ax2.set_xlabel('Temperature')
    ax.set_ylabel('Depth (m)')
    ax.set_title(subplot_titles[i])

    # Invert the y-axis to represent depth as negative down from the surface
    ax.invert_yaxis()

    # Add a legend
    ax.legend()

# Adjust spacing between subplots
plt.tight_layout()

# Show the plot
plt.show()

