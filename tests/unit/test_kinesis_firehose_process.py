import base64
import json

import pytest

from kinesis_firehose_stream_process import app


@pytest.fixture()
def firehose_stream_event():
    """Generates a Kinesis Firehose batch Event."""
    return {
        "invocationId": "invocationIdExample",
        "deliveryStreamArn": "arn:aws:kinesis:EXAMPLE",
        "region": "eu-west-1",
        "records": [
            {
            "recordId": "49546986683135544286507457936321625675700192471156785154",
            "approximateArrivalTimestamp": 1495072949453,
            "data": "eyJjbGllbnRpZCI6ICIwMDAxMjM0IiwgInBhZ2VHZW5kZXIiOiAiTSJ9"
            }
        ]
    }


def test_lambda_handler(firehose_stream_event, mocker):
    result = app.lambda_handler(firehose_stream_event, "")
    payload = base64.b64decode(result["records"][0]["data"]).decode('utf-8')
    data = json.loads(payload)
    assert data["timestamp"] == firehose_stream_event["records"][0]["approximateArrivalTimestamp"]
