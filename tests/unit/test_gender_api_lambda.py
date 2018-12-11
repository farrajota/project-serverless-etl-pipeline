import os
import base64
import json

import pytest

os.environ["DYNAMODB_TABLE"] = 'dummy_table_name'
from gender_api_lambda import app


@pytest.fixture()
def api_gateway_event():
    """Generates a API Gateway event."""
    return {
        'httpMethod': 'GET',
        'body': None,
        'resource': '/gender/{clientid}',
        'requestContext': {
            'resourceId': '123456',
            'apiId': '1234567890',
            'resourcePath': '/gender/{clientid}',
            'httpMethod': 'GET',
            'requestId': 'c6af9ac6-7b61-11e6-9a41-93e8deadbeef',
            'accountId': '123456789012',
            'stage': 'prod',
            'identity': {
                'apiKey': None,
                'userArn': None,
                'cognitoAuthenticationType': None,
                'caller': None,
                'userAgent': 'Custom User Agent String',
                'user': None,
                'cognitoIdentityPoolId': None,
                'cognitoAuthenticationProvider':None,
                'sourceIp': '127.0.0.1',
                'accountId': None
            },
            'extendedRequestId': None,
            'path': '/gender/{clientid}'
        },
        'queryStringParameters': None,
        'headers': {
            'Host': '127.0.0.1:3000',
            'User-Agent': 'curl/7.60.0',
            'Accept': '*/*',
            'X-Forwarded-Proto': 'http',
            'X-Forwarded-Port': '3000'
        },
        'pathParameters': {
            'clientid': '0000011000'
        },
        'stageVariables': None,
        'path': '/gender/0000011000',
        'isBase64Encoded': False
    }


def test_lambda_handler(api_gateway_event, mocker):
    mock_table = mocker.patch.object(app, "get_item_dynamodb", return_value={"Item": {"gender": "F"}})
    result = app.lambda_handler(api_gateway_event, "")
    assert result == {
        "statusCode": 200,
        "body": json.dumps({"clientid": "0000011000", "gender": "F"}),
    }