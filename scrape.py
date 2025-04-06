from bs4 import BeautifulSoup
from datetime import datetime
import argparse
import boto3
import json
import requests
import sys

def scrape(url, element, table, dbtable, date_string):
    try:
        # Send a GET request to the webpage
        response = requests.get(url)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx and 5xx)
        
        # Parse the HTML content
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Locate the desired element containing the desired table class
        desired_element = soup.find(element)
        if not desired_element:
            raise ValueError("Element not found.")
        
        desired_table = desired_element.find('table', class_=table)
        if not desired_table:
            raise ValueError("Table not found inside element.")
        
        # Extract table rows and data
        rows = desired_table.find_all('tr')
         # List to store row data as dictionaries
        table_data = [] 

        # Treat the second row of <td> elements as headers
        headers = [cell.get_text(strip=True) for cell in rows[1].find_all('td')] if rows else None
        headers.append('timestamp')

        # Skip the second row since it's used as headers and then walk through the rest of the rows
        for row in rows[2:]:  
            cells = row.find_all('td')
            data = [cell.get_text(strip=True) for cell in cells]
            data.append(date_string)  # Append the timestamp to each row
            
            if headers:
                row_dict = {headers[i]: data[i] for i in range(len(data))}
            else:
                row_dict = {f"column{i+1}": data[i] for i in range(len(data))}
            
            table_data.append(row_dict)

        # Convert the list of dictionaries to JSON
        json_data = json.dumps(table_data, indent=4)
        print(json_data)

        # Load the data into DynamoDB
        with dbtable.batch_writer() as batch:
            for item in table_data:
                batch.put_item(Item=item)
                print(f"Inserted item: {item}")
        print("Data inserted into DynamoDB successfully.")

    except requests.exceptions.RequestException as e:
        print(f"Error occurred while making the HTTP request: {e}")
    except ValueError as e:
        print(f"Data extraction error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(
    )
    parser.add_argument(
        'url', metavar='URL', type=str, nargs='?',
        help="The URL."
    )

    parser.add_argument(
        'element', metavar='ELEMENT', type=str, nargs='?',
        help="The name of the ELEMENT to be parsed (parent object)."
    )

    parser.add_argument(
        'table', metavar='TABLE', type=str, nargs='?',
        help="The name of the TABLE class to be read."
    )

    parser.add_argument(
        'dbtable', metavar='DBTABLE', type=str, nargs='?',
        help="The name of the DYNAMODB TABLE."
    )

    args = parser.parse_args()

    if not args.url:
        print("Error: No URL provided.")
        parser.print_help()
        sys.exit(1)

    if not args.element:
        print("Error: No ELEMENT provided.")
        parser.print_help()
        sys.exit(1)

    if not args.table:
        print("Error: No TABLE provided.")
        parser.print_help()
        sys.exit(1)
    
    if not args.dbtable:
        print("Error: No DYNAMODB TABLE provided.")
        parser.print_help()
        sys.exit(1)

    dynamodb = boto3.resource('dynamodb')
    dbtable = dynamodb.Table(args.dbtable)

    now = datetime.now()
    date_string = now.strftime("%Y-%m-%d %H:%M:%S")
    print(f"Starting scrape at {date_string}")

    scrape(args.url, args.element, args.table, dbtable, date_string)

if __name__ == '__main__':
    main()