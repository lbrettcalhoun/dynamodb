Terraform IaC for a DynamoDB table and supporting resources.

Notes:
  - Variables can be passed in on command line or via terraform.tfvars (not included in this repo).
  - Need an IAM user account with appropriate permissions to create the associated resources. 
  - The python script can be used to scrape a website for table data.

Shortcuts:
  - Each GSI uses the same range key
  - Each GSI uses the "ALL" projection type
  - The table billing mode is "PROVISIONED"
  - The table TTL attribute is "TTL" and TTL is enabled

Missing:
  - PITR
  - Streams
