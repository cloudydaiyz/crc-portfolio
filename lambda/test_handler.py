import json
import handler
import template
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

    # Create a session
    session = boto3.Session()

    # Use the lambda_handler for the test
    for i in range(len(test_data)):
        data_template = template.make_template(test_data[i]['path'], test_data[i]['method'])
        data = json.loads(data_template)
        print(f'Test number: {i + 1}')

        print('Function: handler')
        result = handler.lambda_handler(data, None, session)
        print()
        print('Test result:')
        print(result)
        print('\n')

if __name__ == '__main__':
    pytest.main()