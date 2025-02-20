import json
import boto3

# Checks whether the event has the right parameters since they'll be accessed in
# the handler
def check_event(event):
    if 'params' not in event \
        or 'path' not in event['params'] \
        or 'counter-type' not in event['params']['path']:
        raise Exception('malformed event params')
    
    if event['params']['path']['counter-type'] != 'github' \
        and event['params']['path']['counter-type'] != 'portfolio':
        raise Exception('invalid event params')
    
    if 'context' not in event \
        or 'http-method' not in event['context']:
        raise Exception('malformed http method')
    
    if event['context']['http-method'] != 'GET' \
        and event['context']['http-method'] != 'POST':
        raise Exception('invalid http method')

ddb = boto3.resource('dynamodb')

def lambda_handler(event, context, session=None, config=None):
    try:
        print(event)
        check_event(event)
    except Exception as err:
        return {
            'statusCode': 400,
            'body': json.dumps('Exception encountered: ' + str(err))
        }

    # Decide the type of counter based on path params
    counter_type = event['params']['path']['counter-type']
    counter_id = 0
    if(counter_type == 'github'):
        counter_id = 1
    elif(counter_type == 'portfolio'):
        counter_id = 2

    # Create a session if specified (in AWS usually won't be specified)
    global ddb
    if session:
        ddb = session.resource('dynamodb', config=config)
    visits_tbl = ddb.Table('Visits')

    # Retrieve the current count
    if event['context']['http-method'] == 'GET':
        current = visits_tbl.get_item(
            Key = {
                'Type': counter_type,
                'CounterID': counter_id
            }
        )
        print(current)
        if 'Item' in current:
            body = {
                'count': int(current['Item']['Amt'])
            }
        else:
            body = {
                'count': 0
            }

    # Update the current count and return the new count
    elif event['context']['http-method'] == 'POST':
        updated = visits_tbl.update_item(
            Key = {
                'Type': counter_type,
                'CounterID': counter_id
            },
            UpdateExpression = 'ADD Amt :inc',
            ExpressionAttributeValues = {
                ':inc': 1
            },
            ReturnValues = 'UPDATED_NEW'
        )
        print(updated)
        body = {
            'count': int(updated['Attributes']['Amt'])
        }

    return {
        'statusCode': 200,
        'body': body
    }