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