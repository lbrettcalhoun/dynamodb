# A list of objects, each object contains an attribute's name and type.
variable "attribute_definitions" {
  description = "The attribute definitions for the DynamoDB table"
  type = list(object({
    attribute_name = string
    attribute_type = string
  }))
}

variable ex_role {
  description = "The IAM role to be used for execute access to the Lambda report function"
  type        = string
  default     = "dynamodb-role-ex"

  validation {
    condition     = length(var.ex_role) > 0
    error_message = "The IAM role must not be empty."
  }
}

variable ex_user {
  description = "The IAM user to be used for execute access to the Lambda report function"
  type        = string
  default     = "dynamodb-user-ex"

  validation {
    condition     = length(var.ex_user) > 0
    error_message = "The IAM user must not be empty."
  }
}

variable function_description {
  description = "The description of the Lambda function"
  type        = string
  default     = "My lambda function"
}

variable function_name {
  description = "The name of the Lambda function"
  type        = string
  default     = "my-lambda-function"
}


# A list of strings, each string is the name of a GSI hash key.
# This variable is used to create multiple GSIs. 
# Note that each GSI will have the same range key (see main.tf ... possible future improvement).
variable "gsi_hash_keys" {
  description = "The hash key(s) for the Global Secondary Index(es) (GSI)"
  type        = list(string)
  default     = null

  # Wow, this is slick! The validation block is used to check if the GSI hash key(s) are 1 of the attribute definitions.
  # The alltrue function is used to check if all elements in the list are true.
  validation {
    condition     = alltrue([for i in var.gsi_hash_keys : contains(var.attribute_definitions[*].attribute_name, i)])
    error_message = "The GSI hash key(s) must be 1 of the attribute definitions."
  }
}

variable "hash_key" {
  description = "The hash key for the DynamoDB table"
  type        = string

  validation {
    condition     = contains(var.attribute_definitions[*].attribute_name, var.hash_key)
    error_message = "The hash key must be 1 of the attribute definitions."
  }
}

variable "part_value" {
  description = "The partition key search value to be passed (as an env var) to the lambda function"
  type        = string
}

variable "range_key" {
  description = "The range key for the DynamoDB table"
  type        = string

  validation {
    condition     = contains(var.attribute_definitions[*].attribute_name, var.range_key)
    error_message = "The range key must be 1 of the attribute definitions."
  }
}

variable rd_role {
  description = "The IAM role to be used for read access to the DynamoDB table"
  type        = string
  default     = "dynamodb-role-rd"

  validation {
    condition     = length(var.rd_role) > 0
    error_message = "The IAM role must not be empty."
  }
}

variable rd_user {
  description = "The IAM user to be used for read access to the DynamoDB table"
  type        = string
  default     = "dynamodb-user-rd"

  validation {
    condition     = length(var.rd_user) > 0
    error_message = "The IAM user must not be empty."
  }
}

variable "rcu" {
  description = "The read capacity units for the DynamoDB table"
  type        = number
  default     = 5

  validation {
    condition     = var.rcu > 0 && var.rcu <= 10
    error_message = "The read capacity units must be between 1 and 10."
  }
}

variable "sort_value" {
  description = "The sort key search value to be passed (as an env var) to the lambda function"
  type = string
}

variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string

}

variable "wcu" {
  description = "The write capacity units for the DynamoDB table"
  type        = number
  default     = 5

  validation {
    condition     = var.wcu > 0 && var.wcu <= 10
    error_message = "The write capacity units must be between 1 and 10."
  }
}

variable wr_role {
  description = "The IAM role to be used for write access to the DynamoDB table"
  type        = string
  default     = "dynamodb-role-wr"

  validation {
    condition     = length(var.wr_role) > 0
    error_message = "The IAM role must not be empty."
  }
}

variable wr_user {
  description = "The IAM user to be used for write access to the DynamoDB table"
  type        = string
  default     = "dynamodb-user-wr"

  validation {
    condition     = length(var.wr_user) > 0
    error_message = "The IAM user must not be empty."
  }
}