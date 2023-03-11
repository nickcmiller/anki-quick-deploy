import json

def lambda_handler(event, context):
    print(event)
    response = {
        "message": "Hello",
        "data": {
            "Key": "Value"
        }
    }
    
    return {
        "statusCode": 200,
        "body": json.dumps(response)
    }
