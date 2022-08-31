terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-dynamodb"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

locals {
  environment_slug = "${terraform.workspace}"
}

resource "aws_dynamodb_table" "agencies_table" {
  name           = "agencies-${local.environment_slug}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "Partition"
  range_key      = "Sort"

  attribute {
    name = "Partition"
    type = "S"
  }

  attribute {
    name = "Sort"
    type = "S"
  }

  attribute {
    name = "LSI"
    type = "S"
  }

  local_secondary_index {
    name            = "ParentIdIndex"
    range_key       = "LSI"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "producer_table" {
  name           = "producer-${local.environment_slug}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "AgencyId"
  range_key      = "SurveyId"

  attribute {
    name = "AgencyId"
    type = "S"
  }

  attribute {
    name = "SurveyId"
    type = "S"
  }
}
