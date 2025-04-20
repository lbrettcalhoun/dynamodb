import boto3
import os


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
    table_name = os.getenv("TABLE_NAME", "dynamotable")
    items = fetch_dynamodb_items(table_name)
    html_table = generate_html_table(items)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html"},
        "body": html_table
    }