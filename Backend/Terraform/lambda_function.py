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

def lambda_handler(event, context):
    method = event['httpMethod']
    
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
