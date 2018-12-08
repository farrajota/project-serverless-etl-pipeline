import base64
import json


def lambda_handler(event, context):
    """Appends a timestamp to the kinesis firehose stream data."""
    output = []

    for record in event['records']:
        payload = base64.b64decode(record['data']).decode('utf-8')
        data = json.loads(payload)

        # add timestamp to the record
        data["timestamp"] = record['approximateArrivalTimestamp']  # add timestamp to record
        new_payload = json.dumps(data)

        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(new_payload.encode('utf-8')).decode('utf-8')
        }
        output.append(output_record)

    return {'records': output}