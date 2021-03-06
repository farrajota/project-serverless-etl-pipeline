import os
import datetime
import time
from tqdm import tqdm
import random
import numpy as np
import boto3
import json
import argparse


def generate_data(n=50):
    """Generates ``n` visitors."""
    data = [generate_data_client() for i in range(n)]
    return data


def generate_data_client(min=1000, max=1100):
    """Generates a random client_id and gender."""
    percentage = np.random.uniform()
    client_id = np.random.randint(min, max)
    return {
        "clientid": f"{client_id}".zfill(10),
        "pageGender": random.choices(['M', 'F'], [percentage, 1 - percentage])[0],
        #"timestamp": str(datetime.datetime.now())
    }


def send_record_firehose(firehose, kinesis_stream, data):
    """Sends a record to Kinesis Firehose."""
    delivery_stream_name = kinesis_stream
    response = firehose.put_record(
        DeliveryStreamName=delivery_stream_name,
        Record={
            'Data': json.dumps(data)
        }
    )
    return response


def main(n=10, kinesis_stream=""):
    """Main function."""
    # rng seed
    np.random.seed(123)

    # Firehose client
    firehose = boto3.client(
        service_name="firehose",
        region_name="eu-west-1",
        aws_access_key_id=os.environ["AWS_ACCESS_KEY"],
        aws_secret_access_key=os.environ["AWS_SECRET_KEY"]
    )

    # Generates N records per second
    while(1):
        for i in tqdm(range(n)):
            data = generate_data_client()
            response = send_record_firehose(firehose, kinesis_stream, data)
            time.sleep(0.005)
        time.sleep(1 - n * 0.005)

if __name__ == '__main__':
    # parse input args
    parser = argparse.ArgumentParser(description='Generate streams of dummy data.')
    parser.add_argument('-r', '--requests-per-second', default=10,
                        help='Number of requests per second.')
    parser.add_argument('-s', '--kinesis_stream_name', default="kinesis_firehose_stream",
                        help='AWS Kinesis Firehose Stream name.')
    args = parser.parse_args()

    # run main function
    main(n=args.requests_per_second, kinesis_stream=args.kinesis_stream_name)
