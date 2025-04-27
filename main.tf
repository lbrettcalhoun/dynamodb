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



