# import pandas as pd
# import matplotlib.pyplot as plt
# import pandas as pd
# import matplotlib.pyplot as plt

# # Load the data
# data_path = '/Users/user/Desktop/reduced_data.csv'  # Replace with your CSV file path
# data = pd.read_csv(data_path)

# # Drop rows with any 'NA' values
# data = data.dropna()

# # Convert to numeric and filter out unrealistic values
# data['CTD.Salinity'] = pd.to_numeric(data['CTD.Salinity'], errors='coerce')
# data['CTD.Temperature'] = pd.to_numeric(data['CTD.Temperature'], errors='coerce')
# data = data[(data['CTD.Salinity'] > 0) & (data['CTD.Salinity'] < 40)]  # Assuming salinity range
# data = data[(data['CTD.Temperature'] > -5) & (data['CTD.Temperature'] < 40)]  # Assuming temperature range

# # Creating boxplots for salinity and temperature across seamounts
# fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(14, 6))

# # Salinity Boxplot
# salinity_boxplot = axes[0].boxplot([data['CTD.Salinity'][data['Seamount'] == sm] for sm in data['Seamount'].unique()],
#                                    labels=data['Seamount'].unique(), patch_artist=True)
# axes[0].set_title('Salinity Distribution by Seamount')
# axes[0].set_xlabel('Seamount')
# axes[0].set_ylabel('Salinity')

# # Temperature Boxplot
# temperature_boxplot = axes[1].boxplot([data['CTD.Temperature'][data['Seamount'] == sm] for sm in data['Seamount'].unique()],
#                                       labels=data['Seamount'].unique(), patch_artist=True)
# axes[1].set_title('Temperature Distribution by Seamount')
# axes[1].set_xlabel('Seamount')
# axes[1].set_ylabel('Temperature (°C)')

# plt.xticks(rotation=45)
# plt.tight_layout()
# plt.show()


import pandas as pd
import matplotlib.pyplot as plt

# Load the data
data_path = '/Users/user/Desktop/corrected_data.csv'  # Replace with your CSV file path
data = pd.read_csv(data_path)

# Drop rows with any 'NA' values
data = data.dropna()

# Convert to numeric and filter out unrealistic values
# data['CTD.Salinity'] = pd.to_numeric(data['CTD.Salinity'], errors='coerce')
# data['CTD.Temperature'] = pd.to_numeric(data['CTD.Temperature'], errors='coerce')
# data = data[(data['CTD.Salinity'] > 0) & (data['CTD.Salinity'] < 40)]  # Assuming salinity range
# data = data[(data['CTD.Temperature'] > -5) & (data['CTD.Temperature'] < 40)]  # Assuming temperature range

# Creating boxplots for salinity and temperature across seamounts
fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(14, 6))

# Salinity Boxplot
salinity_boxplot = axes[0].boxplot([data['CTD.Salinity'][data['Seamount'] == sm] for sm in data['Seamount'].unique()],
                                   labels=data['Seamount'].unique(), patch_artist=True)
axes[0].set_title('Salinity Distribution by Seamount')
axes[0].set_xlabel('Seamount')
axes[0].set_ylabel('Salinity')

# Temperature Boxplot
temperature_boxplot = axes[1].boxplot([data['CTD.Temperature'][data['Seamount'] == sm] for sm in data['Seamount'].unique()],
                                      labels=data['Seamount'].unique(), patch_artist=True)
axes[1].set_title('Temperature Distribution by Seamount')
axes[1].set_xlabel('Seamount')
axes[1].set_ylabel('Temperature (°C)')

plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
