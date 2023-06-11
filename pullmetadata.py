import pandas as pd
import pdb

# Read the first CSV file into a dataframe (target dataframe)
df1 = pd.read_csv('/Users/user/Desktop/metadata_flow/2.+LATLON/reportD8F5.csv')

# Read the second CSV file into another dataframe (source dataframe)
df2 = pd.read_csv('/Users/user/Desktop/metadata_flow/3.MERGEDTELEMETRIES/merged_dive8file5.csv')

# change the column name on the merged telemetries file from Timestamp to capture_time
# to match biigle output report column name 
df2 = df2.rename(columns = {'Timestamp' : 'capture_time'})

# Convert the 'capture_time' column in dataframe1 and 2 to datetime64[ns] data type
df2['capture_time'] = pd.to_datetime(df2['capture_time'], format = '%d.%m.%Y %H:%M:%S')
df1['capture_time'] = pd.to_datetime(df1['capture_time'], format = '%Y.%m.%d %H:%M:%S')

# checking dataframes
print(df1['capture_time'].head())
print(df2['capture_time'].head())


#checking for duplications in the merged file (df2)
# df2['capture_time'] = df2['capture_time'].drop_duplicates()

# if df2['capture_time'].duplicated().any():
#     df2 = df2.drop_duplicates(subset=['capture_time'])
#     print('yes')

# duplicates_exist = df2['capture_time'].duplicated().any()

# if duplicates_exist:
#     print('Duplicates still exist in df2')
# else:
#     print('No duplicates in df2')

# # Assign the result of drop_duplicates() back to df2
# df2 = df2.drop_duplicates(subset=['capture_time'])
# df2 = df2.reset_index(drop=True)

# #removing rows with NaN values in dataframe 2
# df2.dropna(inplace=True)


# pdb.set_trace()

# select the columns from df2 that you want to use for the merge. You have to also select capture_time
# as this is what you are merging by!
df2_subset = df2[['capture_time','CTD.Temperature', 'CTD.Salinity', 'CTD.Pressure', 'ROV.RovDepth']]

#checking data
#print(df2_subset[['capture_time','CTD.Temperature', 'CTD.Salinity', 'CTD.Pressure', 'ROV.RovDepth']].head(10))

# Merge the data frames based on the common column 'capture_time'
merged_df = pd.merge(df1, df2_subset, on = 'capture_time', how = 'inner')

# Save the merged dataframe to a new CSV file
merged_df.to_csv('~/Desktop/metadata_flow/4.+TSPD/Melville_metadata/MERGEDDIVE8f5.csv', index = False)

