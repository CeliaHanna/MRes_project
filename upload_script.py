import os
import boto3
import tqdm
import sys
import subprocess

s3 = boto3.client('s3')
s3_bucket_name = 'celiaproject'
# fname = "/Users/user/Desktop/File2Dive11JC66_1.mov"
filename = sys.argv[1]


_format = ''
if ".flv" in filename.lower():
    _format=".flv"
if ".mp4" in filename.lower():
    _format=".mp4"
if ".avi" in filename.lower():
    _format=".avi"
if ".mov" in filename.lower():
    _format=".mov"


print('[INFO] 1',filename)
basename = os.path.basename(filename)
outputfile = os.path.join("/tmp/", basename.lower().replace(_format, ".mp4"))
print("tmp mp.4 file is at:", outputfile)
subprocess.call(['ffmpeg', '-i', filename, "-c:v", "libx264", "-c:a", "aac", "-strict", "experimental", outputfile])  

assert os.path.exists(outputfile)


def upload(fname):
    statinfo = os.stat(fname)
    with tqdm.tqdm(total=statinfo.st_size) as pbar:
        s3.upload_file(
            fname, 
            'celiaproject', 
            os.path.basename(fname), 
            ExtraArgs={'ContentType': "video/mp4"}, 
            Callback=lambda x: pbar.update(x)
        )

    bucket_location = boto3.client('s3').get_bucket_location(Bucket=s3_bucket_name)
    object_url = "https://s3-{0}.amazonaws.com/{1}/{2}".format(
        bucket_location['LocationConstraint'],
        s3_bucket_name,
        os.path.basename(fname))
    
    print(f'file successfully uploaded to: {object_url}')


upload(outputfile)

