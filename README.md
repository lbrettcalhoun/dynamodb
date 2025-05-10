# Terraform IaC for a DynamoDB table and supporting resources.

## Notes:
1. Variables can be passed in on command line or via terraform.tfvars (not included in this repo).
2. Need an IAM user account with appropriate permissions to create the associated resources (not included in this repo). 
3. Need IAM user account(s) to be used for DynamoDB table reads, writes and Lambda executions (not included in this repo).
4. The python script can be used to scrape a website for table data.
5. Need Postman (or another suitable client) to access the function URL.

### Additional Note: Function URL currently disabled

### Recommendations:
1. A python virtual environment

### What you get:
1. A DynamoDB table: Use this table to store stuff
2. A Lambda function: Use this function to generate an HTML report of your table
3. A Lambda function URL: Use this function URL to access your report via Postman
4. Python script: Use this command line script to add data to your table
5. Roles:
    - DynamoDB table read role
    - DynamoDB table write role
    - Lambda execution role

### Shortcuts:
1. Each GSI uses the same range key
2. Each GSI uses the "ALL" projection type
3. The table billing mode is "PROVISIONED"
4. The table TTL attribute is "TTL" and TTL is enabled
5. The fetch_dynamodb_items function casts part_value to integer

### Missing:
1. PITR
2. Streams
