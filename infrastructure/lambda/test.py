import json
import test_handler
import handler
import secret
import boto3
from botocore.config import Config

def handler_test(use_handler=False, use_test_handler=True):
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

        if(use_test_handler):
            print('Function: test_handler')
            result = test_handler.lambda_handler(data, None, session, config)
            print()
            print('Test result:')
            print(result)
            print('\n')
        
        if(use_handler):
            print('Function: handler')
            result = handler.lambda_handler(data, None, session, config)
            print()
            print('Test result:')
            print(result)
            print('\n')

if __name__ == '__main__':
    handler_test(True, False)