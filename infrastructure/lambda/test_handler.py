"""
Purpose

Shows how to implement an AWS Lambda function that handles input from direct
invocation, and manipulates entries in a DynamoDB table.
"""

import json
import boto3

# From AWS: Take advantage of execution environment reuse to improve the performance 
# of your function. Initialize SDK clients and database connections outside of the 
# function handler
# https://docs.aws.amazon.com/lambda/latest/dg/deploying-functions-best-practices.html
ddb = boto3.resource('dynamodb')

def lambda_handler(event, context, session=None, config=None):
    """
    Accepts an action and a single number, performs the specified action on the number,
    and returns the result. The only allowable action is 'increment'.

    :param event: The event dict that contains the parameters sent when the function
                  is invoked.
    :param context: The context in which the function is called.
    :return: The result of the action.
    """
    global ddb
    print(event)
    print(context)
    
    type = 'regular'
    value = 1
    if 'Type' in event:
        type = event['Type']
    if 'CounterID' in event:
        value = event['CounterID']
    print(type, value)
    
    # For testing
    if session != None and config != None:
        ddb = session.resource('dynamodb', config=config)
    
    visits_tbl = ddb.Table('Visits')
    print(visits_tbl)
    
    # From AWS: If there is no matching item, GetItem does not return any data and there 
    # will be no Item element in the response.
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/table/get_item.html
    current = visits_tbl.get_item(
        Key = {
            'Type': type,
            'CounterID': value
        }
    )
    print(current)
    
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/table/update_item.html
    next = visits_tbl.update_item(
        Key = {
            'Type': type,
            'CounterID': value
        },
        UpdateExpression = 'ADD Amt :inc',
        ExpressionAttributeValues = {
            ':inc': 1
        },
        ReturnValues = 'UPDATED_NEW'
    )
    print(next)
    
    print('done')
    
    message = "No message for you"
    result = {
        'statusCode': 200,
        'message': message,
        'body': json.dumps('Hello from Lambda!')
    }
    
    if 'Item' in current:
        result['current'] = current['Item']['Amt']
    result['next'] = next['Attributes']['Amt']
    
    return result