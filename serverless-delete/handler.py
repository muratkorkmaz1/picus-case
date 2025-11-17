import json
import os
import boto3

dynamo = boto3.client("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]


def _response(status_code: int, body: dict):
    return {
        "statusCode": status_code,
        "statusDescription": f"{status_code} OK" if status_code < 400 else f"{status_code} Error",
        "isBase64Encoded": False,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body),
    }


def delete_picus_item(event, context):
    """
    ALB event örneği:
    {
      "httpMethod": "DELETE",
      "path": "/picus/123",
      ...
    }
    """
    path = event.get("path", "") or ""
    path = path.rstrip("/")
    key = path.split("/")[-1] if "/" in path else ""

    if not key or key == "picus":
        return _response(400, {"error": "Missing key in path, expected /picus/{key}"})

    try:
        dynamo.delete_item(
            TableName=TABLE_NAME,
            Key={"id": {"S": key}},
        )
    except Exception as e:
        # Gerçek hayatta burada log atılır (CloudWatch)
        return _response(500, {"error": "DynamoDB delete failed", "detail": str(e)})

    return _response(200, {"deleted": key})
