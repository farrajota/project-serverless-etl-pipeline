import os
import math
import datetime
import time
from tqdm import tqdm
import pandas as pd
import random
import numpy as np


prefix = 'firehose/'

def generate_data(year, month, day):
    """Generates data for a single day and uploads it to S3."""

    # generate fake data
    data_single_day = generate_data_day(nclients=100,
                                        visits_per_day=[5, 30],
                                        ndays=10,
                                        year=year,
                                        month=month,
                                        day=day)

    # convert to pandas dataframe
    df = pd.DataFrame(data_single_day).set_index("clientID")

    # split df into two
    half_size = math.ceil(len(df) / 2)
    df1 = df.iloc[:half_size]
    df2 = df.iloc[half_size:]

    # save to disk
    df1.to_parquet("/tmp/data_split1.parquet", engine="pyarrow", compression="GZIP")
    df2.to_parquet("/tmp/data_split2.parquet", engine="pyarrow", compression="GZIP")

    # upload to s3
    response = upload_to_s3(filenames="/tmp/data_split1.parquet",
                            year=year,
                            month=month,
                            day=day)
    response = upload_to_s3(filenames="/tmp/data_split2.parquet",
                            year=year,
                            month=month,
                            day=day)

    # compute daily hits and store to s3
    daily_hits = compute_daily_hits(df)
    df2.to_parquet("/tmp/daily_hits.parquet", engine="pyarrow", compression="GZIP")

    # upload to s3
    response = upload_to_s3(filenames="/tmp/daily_hits.parquet",
                            year=year,
                            month=month,
                            day=day,
                            add_random_hour=False)


def generate_data_day(nclients=100, visits_per_day=[5, 30], ndays=10, year=2018, month=10, day=20):
    """Generates fake data for ``nclients`` visitors."""
    data_single_day = []
    for client_id in range(1000 + day, 1000 + day + nclients):
        percentage = np.random.uniform()
        num_visits = np.random.randint(visits_per_day[0], visits_per_day[1])
        for visit in range(num_visits):
            data_single_day.append({
                "clientID": f"{client_id}".zfill(10),
                "pageGender": random.choices(['M', 'F'], [percentage, 1 - percentage])[0]
            })

    # shuffle data
    random.shuffle(data_single_day)

    # add random timestamp
    num_visits_day = len(data_single_day)
    datetimes = generate_client_random_datetimes(num_visits_day, year, month, day)

    for ivisit in range(len(data_single_day)):
        data_single_day[ivisit]["timestamp"] = str(datetimes[ivisit])

    return data_single_day


def generate_client_random_datetimes(num_visits, year, month, day):
    """Generates random times for each client throught the day."""
    datetimes = [generate_random_datetime(year, month, day) for i in range(num_visits)]
    ds = pd.Series(datetimes)
    ds_sorted = ds.sort_values()
    return list(ds_sorted)


def generate_random_datetime(year, month, day, min_hour=0, min_minute=0, mint_second=0):
    """Generates a random time."""
    MINTIME = datetime.datetime(year, month, day, min_hour, min_minute, mint_second)
    MAXTIME = datetime.datetime(year, month, day, 23,59,59)

    mintime_ts = int(time.mktime(MINTIME.timetuple()))
    maxtime_ts = int(time.mktime(MAXTIME.timetuple()))

    random_ts = random.randint(mintime_ts, maxtime_ts)
    RANDOMTIME = datetime.datetime.fromtimestamp(random_ts)

    return RANDOMTIME


def upload_to_s3(filename, year, month, day, add_random_hour=True):
    """Uploads data to s3."""
    # s3 file name prefix
    s3_path = f"{year}/{month}/{day}"
    if prefix:
        s3_path = f"{prefix}/{s3_path}"

    s3 = boto3.resource(
        's3',
        region_name="eu-west-1",
        aws_access_key_id=os.environ["AWS_ACCESS_KEY"],
        aws_secret_access_key=os.environ["AWS_SECRET_KEY"]
    )
    bucket = s3.Bucket(os.environ["S3_BUCKET_DEST"])

    # add random hour to path
    if add_random_hour:
        rand_hour = random.randint(0, 23)
        s3_path_filename = os.path.join(s3_path, str(rand_hour), os.path.basename(filename))
    else:
        s3_path_filename = os.path.join(s3_path, os.path.basename(filename))

    # upload file to s3 bucket
    response = bucket.upload_file(filename, s3_path_filename)

    return response


def compute_daily_hits(df):
    """Computes page hits per gender per client in a day."""
    return df.groupby(["clientid", "pageGender"]).count()


def main(days=10):
    """Main function."""
    # rng seed
    np.random.seed(123)

    # generate data for the previous 10 days
    current_time = datetime.datetime.now()
    for i in tqdm(range(1, days+1)):
        time_delta = datetime.time_delta(days=i)
        date = current_time - time_delta
        generate_data(year=date.year,
                      month=date.month,
                      day=date.day)


if __name__ == '__main__':
    # number of days to generate data
    days = 10

    print(f"Generating dummy data for the previous {days} days of the current time...")
    main(days=days)
    print("\nData Generation complete!")