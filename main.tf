terraform {
  required_version = ">= 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Let's use the terraform-aws-modules/lambda/aws module to create the Lambda function.
# This is pretty cool. It creates a builds folder and a deployment package for the function.
# It also creates log groups and IAM roles for the function.
module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.function_name
  description   = var.function_description
  authorization_type = "AWS_IAM"
  attach_policy_json = true
  cloudwatch_logs_retention_in_days = 7
  cors = {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
  create_lambda_function_url = true
  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.self.name
  }
  handler       = "lambda_function.lambda_handler"
  policy_json = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "dynamodb:BatchGetItem",
            "dynamodb:DescribeTable",
            "dynamodb:GetItem",
            "dynamodb:Scan",
            "dynamodb:Query"
          ],
          "Resource": "${aws_dynamodb_table.self.arn}"
        }
      ]
    }
  EOT
  runtime       = "python3.12"
  source_path = "src/lambda_function.py"
  timeout = 30
  

  tags = {
    Name = var.function_name
  }
}

resource "aws_dynamodb_table" "self" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.rcu
  write_capacity = var.wcu
  hash_key       = var.hash_key
  range_key      = var.range_key
  stream_enabled = false

  # So how does this work?
  # The attribute_definitions variable is a list of objects, each object contains an attribute's name and type.
  # This is used to create the table's attributes.
  # The dynamic block is used to create multiple attributes based on the list of objects. Could be 2 attributes or more.
  # The for_each argument is used to iterate over the list of objects and create a block for each object.
  dynamic "attribute" {
    for_each = var.attribute_definitions
    content {
      name = attribute.value.attribute_name
      type = attribute.value.attribute_type
    }
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  # So how does this work?
  # Same as for the attributes, except this time we are using a list of strings instead of a list of objects.
  # The dynamic block is used to create multiple GSIs based on the list of strings.
  # Note that we use global_secondary_index.value to get the value of the current iteration. 
  # And note that our range_key is the same for all GSIs.
  # This is a possible future improvement, we could use a list of objects instead of a list of strings and create multiple range keys.
  dynamic "global_secondary_index" {
    for_each = var.gsi_hash_keys
    content {
      name            = "${var.table_name}-${global_secondary_index.value}-index"
      hash_key        = global_secondary_index.value
      range_key       = var.range_key
      write_capacity  = var.wcu
      read_capacity   = var.rcu
      projection_type = "ALL"
    }
  }

  tags = {
    Name = var.table_name
  }
}

resource "aws_dynamodb_resource_policy" "self" {
  resource_arn = aws_dynamodb_table.self.arn
  policy       = data.aws_iam_policy_document.self.json
}



