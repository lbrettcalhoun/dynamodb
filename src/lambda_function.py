import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def fetch_dynamodb_items(table_name):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(table_name)

    response = table.scan()
    return response.get("Items", [])

def generate_html_table(items):
    if not items:
        return "<p>No data found.</p>"

    headers = items[0].keys()
    html = "<table border='1'><tr>"
    html += "".join(f"<th>{header}</th>" for header in headers)
    html += "</tr>"

    for item in items:
        html += "<tr>" + "".join(f"<td>{item.get(header, '')}</td>" for header in headers) + "</tr>"

    html += "</table>"
    return html

def lambda_handler(event, context):
    logger.info("Lambda function started.")
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")
    table_name = os.getenv("TABLE_NAME", "dynamotable")
    logger.info(f"Fetching items from DynamoDB table: {table_name}")
    items = fetch_dynamodb_items(table_name)
    logger.info(f"Generating HTML table for {len(items)} items.")
    html_table = generate_html_table(items)
    logger.info("Response code: 200")
    logger.info("Lambda function completed successfully.")
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html"},
        "body": html_table
    }