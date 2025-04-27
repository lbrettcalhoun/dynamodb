Terraform IaC for a DynamoDB table and supporting resources.

Notes:
  - Variables can be passed in on command line or via terraform.tfvars (not included in this repo).
  - Need an IAM user account with appropriate permissions to create the associated resources (not included in this repo). 
  - Need IAM user account(s) to be used for DynamoDB table reads, writes and Lambda executions (not included in this repo).
  - The python script can be used to scrape a website for table data.
  - Need Postman (or another suitable client) to access the function URL.

Recommendations:
  - A python virtual environment

What you get:
  - A DynamoDB table: Use this table to store stuff
  - A Lambda function: Use this function to generate an HTML report of your table
  - A Lambda function URL: Use this function URL to access your report via Postman
  - A Python script: Use this command line script to add data to your table
  - Roles:
    - DynamoDB table read role
    - DynamoDB table write role
    - Lambda execution role

Shortcuts:
  - Each GSI uses the same range key
  - Each GSI uses the "ALL" projection type
  - The table billing mode is "PROVISIONED"
  - The table TTL attribute is "TTL" and TTL is enabled

Missing:
  - PITR
  - Streams
