import json
import boto3
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('VisitorCounts')  # Replace with your table name

def decimal_to_int(obj):
    """Helper function to convert Decimal objects to int."""
    if isinstance(obj, Decimal):
        return int(obj)
    raise TypeError

def create_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': 'https://www.skillspheres.com',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
            'Content-Type': 'application/json'
        },
        'body': json.dumps(body, default=decimal_to_int)
    }

def lambda_handler(event, context):
    try:
        method = event['httpMethod']
        
        # Handle OPTIONS preflight request
        if method == 'OPTIONS':
            return create_response(200, {'message': 'CORS preflight successful'})
        
        if method == 'GET':
            response = table.get_item(Key={'PageID': 'home'})
            count = response.get('Item', {}).get('VisitorCount', 0)
            return create_response(200, {'VisitorCount': count})
        
        elif method == 'POST':
            response = table.update_item(
                Key={'PageID': 'home'},
                UpdateExpression='SET VisitorCount = if_not_exists(VisitorCount, :start) + :inc',
                ExpressionAttributeValues={
                    ':start': Decimal(0),
                    ':inc': Decimal(1)
                },
                ReturnValues='UPDATED_NEW'
            )
            visitor_count = response['Attributes']['VisitorCount']
            return create_response(200, {
                'message': 'Visitor count incremented!',
                'VisitorCount': visitor_count
            })
        
        else:
            return create_response(405, {'message': 'Method Not Allowed'})
            
    except Exception as e:
        return create_response(500, {'error': str(e)})


"""
def lambda_handler(event, context):
    try:
    method = event['httpMethod']
    
    # Handle OPTIONS method for CORS preflight
    if method == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps({'message': 'CORS preflight successful'})
        }

    if method == 'GET':  # Fetch current count
        response = table.get_item(Key={'PageID': 'home'})  # Replace 'home' with your actual page ID
        count = response.get('Item', {}).get('VisitorCount', 0)
        
        return {
            'statusCode': 200,
            'body': json.dumps({'VisitorCount': count}, default=decimal_to_int)
        }
    
    elif method == 'POST':  # Increment count
        # Atomic increment using DynamoDB's update_item
        response = table.update_item(
            Key={'PageID': 'home'},  # Replace 'home' with your actual page ID
            UpdateExpression='SET VisitorCount = if_not_exists(VisitorCount, :start) + :inc',
            ExpressionAttributeValues={
                ':start': Decimal(0),  # Default value if VisitorCount doesn't exist
                ':inc': Decimal(1)     # Increment by 1
            },
            ReturnValues='UPDATED_NEW'
        )
        
        # Extract the updated VisitorCount from the response
        visitor_count = response['Attributes']['VisitorCount']
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Visitor count incremented!', 'VisitorCount': visitor_count}, default=decimal_to_int)
        }
    
    else:
        return {
            'statusCode': 405,
            'body': json.dumps({'message': 'Method Not Allowed'})
        }
"""