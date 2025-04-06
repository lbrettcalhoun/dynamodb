# A list of objects, each object contains an attribute's name and type.
variable "attribute_definitions" {
  description = "The attribute definitions for the DynamoDB table"
  type = list(object({
    attribute_name = string
    attribute_type = string
  }))
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

variable "range_key" {
  description = "The range key for the DynamoDB table"
  type        = string

  validation {
    condition     = contains(var.attribute_definitions[*].attribute_name, var.range_key)
    error_message = "The range key must be 1 of the attribute definitions."
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

variable role {
  description = "The IAM role to be used for access to the DynamoDB table"
  type        = string
  default     = "dynamodb-role"

  validation {
    condition     = length(var.role) > 0
    error_message = "The IAM role must not be empty."
  }
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