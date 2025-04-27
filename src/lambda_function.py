import boto3
import botocore.exceptions
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def fetch_dynamodb_items(table_name):
    try:
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table(table_name)

        response = table.scan()
        return response.get("Items", [])
    except botocore.exceptions.ClientError as e:
        # Handle AWS service-specific errors
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        logger.error(f"ClientError: {error_code} - {error_message}")
        return []  # Return an empty list if an error occurs
    except botocore.exceptions.BotoCoreError as e:
        # Handle generic botocore errors
        logger.error(f"BotoCoreError: {e}")
        return []  # Return an empty list if an error occurs
    except Exception as e:
        # Handle any other unexpected errors
        logger.error(f"Unexpected error occurred: {e}")
        return []  # Return an empty list for any other unexpected errors

def generate_html_table(items):
    try:
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
    except KeyError as e:
        logger.error(f"KeyError while generating HTML table: {e}")
        return "<p>Error generating table: Missing data.</p>"
    except Exception as e:
        logger.error(f"Unexpected error occurred while generating HTML table: {e}")
        return "<p>Error generating table.</p>"

def lambda_handler(event, context):
    logger.info("Lambda function started.")
    logger.info(f"Event: {event}")
    logger.info(f"Context: {context}")
    
    table_name = os.getenv("TABLE_NAME", "dynamotable")
    logger.info(f"Fetching items from DynamoDB table: {table_name}")
    
    try:
        # Fetch items from DynamoDB
        items = fetch_dynamodb_items(table_name)
        
        # Generate HTML table
        logger.info(f"Generating HTML table for {len(items)} items.")
        html_table = generate_html_table(items)
        
        # Check for "No data found" or "Error generating table" in the HTML table
        if "No data found" in html_table or "Error generating table" in html_table:
            logger.error("HTML table generation failed or no data was found.")
            return {
                "statusCode": 500,
                "headers": {"Content-Type": "text/html"},
                "body": html_table
            }
        
        # Return success response
        logger.info("Lambda function completed successfully.")
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "text/html"},
            "body": html_table
        }
    except Exception as e:
        # Handle any unexpected errors
        logger.error(f"Unexpected error occurred: {e}")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "text/html"},
            "body": "<p>Server error: An unexpected error occurred.</p>"
        }