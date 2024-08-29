import json
import handler
import secret
import boto3
from botocore.config import Config
import pytest

def test_handler():
    test_data = [
        {
            "path": "github",
            "method": "GET"
        },
        {
            "path": "portfolio",
            "method": "GET"
        },
        {
            "path": "github",
            "method": "POST"
        },
        {
            "path": "portfolio",
            "method": "POST"
        }
    ]

    # Create a session to use the kduncan profile
    session = boto3.Session(profile_name='kduncan')

    # Create a config to ensure the region is us-east-2
    config = Config(region_name='us-east-2')

    # Use the lambda_handler for the test
    for i in range(len(test_data)):
        data_template = secret.make_template(test_data[i]['path'], test_data[i]['method'])
        data = json.loads(data_template)
        print(f'Test number: {i + 1}')

        print('Function: handler')
        result = handler.lambda_handler(data, None, session, config)
        print()
        print('Test result:')
        print(result)
        print('\n')

if __name__ == '__main__':
    pytest.main()