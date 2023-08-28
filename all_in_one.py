import os
import datetime
from timestampcode import add_timestamp_to_csv
from latlon_to_multiple_csvs import addlatlon
from pullTSPD import add_tspd
from addslope import add_gradient
from addduration import add_duration

LAT_LON_DIR = '/Users/user/Desktop/metadata_flow/original_csvs'
TSPD_DIR = '/Users/user/Desktop/metadata_flow/3.MERGEDTELEMETRIES'
GRADIENT_DIR = '/Users/user/Desktop/metadata_flow/gradient_info'

VIDEO_START_TIMES = {
        'coral-dive2-file4.csv': datetime.datetime(2011, 11, 12, 12, 00, 00),
        'coral-dive1-file5.csv': datetime.datetime(2011, 11, 12, 14, 1, 0), 
        'coral-dive2-file2.csv': datetime.datetime(2011, 11, 13, 7, 31, 0),
        'coral-dive2-file4.csv': datetime.datetime(2011, 11, 13, 11, 34, 0),
        'coral-dive2-file5.csv': datetime.datetime(2011, 11, 13, 13, 49, 0),
        'coral-dive3-file4.csv': datetime.datetime(2011, 11, 14, 11, 0, 0),
        'coral-dive3-file5.csv': datetime.datetime(2011, 11, 14, 13, 13, 0),
        'coral-dive4-file2.csv': datetime.datetime(2011, 11, 16, 5, 14, 0),
        'coral-dive5-file1.csv': datetime.datetime(2011, 11, 20, 3, 19, 0),
        'coral-dive5-file2.csv': datetime.datetime(2011, 11, 20, 5, 22, 0),
        'coral-dive1-file4.csv': datetime.datetime(2011, 11, 20, 12, 0, 0)
        
        } 

LAT_LON_dict = {
        'coral-dive2-file4.csv':'dive2.csv',
        'coral-dive1-file5.csv':'dive1.csv',
        'coral-dive2-file2.csv':'dive2.csv',
        'coral-dive2-file4.csv':'dive2.csv',
        'coral-dive2-file5.csv':'dive2.csv',
        'coral-dive3-file4.csv':'dive3.csv',
        'coral-dive3-file5.csv':'dive3.csv',
        'coral-dive4-file2.csv':'dive4.csv',
        'coral-dive5-file1.csv':'dive5.csv',
        'coral-dive5-file2.csv':'dive5.csv',
        'coral-dive1-file4.csv': 'dive1.csv'

}

TSPD_file_paths = {
        'coral-dive2-file4.csv':'merged_ALLdive2.csv',
        'coral-dive1-file5.csv':'merged_ALLdive1.csv', 
        'coral-dive2-file2.csv':'merged_ALLdive2.csv',
        'coral5-dive2-file4.csv':'merged_ALLdive2.csv',
        'coral-dive2-file5.csv':'merged_ALLdive2.csv',
        'coral-dive3-file4.csv':'merged_ALLdive3.csv',
        'coral-dive3-file5.csv':'merged_ALLdive3.csv',
        'coral-dive4-file2.csv':'merged_ALLdive4.csv',
        'coral-dive5-file1.csv':'merged_ALLdive5.csv',
        'coral-dive5-file2.csv':'merged_ALLdive5.csv',
        'coral-dive1-file4.csv': 'merged_ALLdive1.csv'

}

GRADIENT_dict = {
        'coral-dive2-file4.csv':'dive2slopes.csv',
        'coral-dive1-file5.csv':'dive1slopes.csv', 
        'coral-dive2-file2.csv':'dive2slopes.csv',
        'coral-dive2-file4.csv':'dive2slopes.csv',
        'coral-dive2-file5.csv':'dive2slopes.csv',
        'coral-dive3-file4.csv':'dive3slopes.csv',
        'coral-dive3-file5.csv':'dive3slopes.csv',
        'coral-dive4-file2.csv':'dive4slopes.csv',
        'coral-dive5-file1.csv':'dive5slopes.csv',
        'coral-dive5-file2.csv':'dive5slopes.csv',
        'coral-dive1-file4.csv': 'dive1slopes.csv'

}

for key in LAT_LON_dict:
    LAT_LON_dict[key] = os.path.join(LAT_LON_DIR, LAT_LON_dict[key])
for key in TSPD_file_paths:
    TSPD_file_paths[key] = os.path.join(TSPD_DIR, TSPD_file_paths[key])
for key in GRADIENT_dict:
    GRADIENT_dict[key] = os.path.join(GRADIENT_DIR, GRADIENT_dict[key])

print(LAT_LON_dict)



if __name__ == '__main__':

    # Define the directory where your CSV files are located
    csv_directory = '/Users/user/Desktop/metadata_flow/biiglereports_raw/CORAL'
    # List all CSV files in the directory
    csv_files = os.listdir(csv_directory)
    save_directory = '/Users/user/Desktop/metadata_flow/completed_metadata_files'
    if not os.path.exists(save_directory):
        os.makedirs(save_directory)

    for csv_file in csv_files:
        if not csv_file.endswith(".csv"):
            print("found non csv", csv_file)
            continue
        #csv_file = 'coral-dive2-file4.csv'

        file_path = os.path.join(csv_directory, csv_file)

        video_start_time = VIDEO_START_TIMES[csv_file]


        #if video_start_time:
        print('Adding Timestamps')
        df = add_timestamp_to_csv(file_path, video_start_time, return_df = True)

        print('Adding Lat Lon')

        lat_long_file = LAT_LON_dict.get(csv_file)
        print(lat_long_file)
        assert os.path.exists(lat_long_file)

        df = addlatlon(lat_long_file, df, return_df = True)
        
        # if 'dive3'in csv_file:

        #     breakpoint()
        print('Adding temperature, salinity, pressure, depth')
        tspd_file_path = TSPD_file_paths.get(csv_file)

        df = add_tspd(tspd_file_path, df, return_df=True)
        if df.empty:
            breakpoint()

        print('Adding gradient')
        gradient_file = GRADIENT_dict.get(csv_file)
        print(gradient_file)
        df = add_gradient(gradient_file, df, return_df = True)

        print('Adding duration')
        df = add_duration(df, return_df = True)
        save_file_path = os.path.join(save_directory, csv_file)
        df.to_csv(save_file_path, index=False)
        print("Conversion completed. New CSV file saved. with",csv_file)
