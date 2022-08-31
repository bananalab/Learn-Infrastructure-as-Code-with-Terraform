terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-kms"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-locks"
  }
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

locals {
  environment_slug = lower(terraform.workspace)
}

resource "aws_kms_key" "rojopolis_key" {
  description = "Encrypts sensitive fields in rojopolis API"
}

resource "aws_kms_alias" "rojopolis_key_alias" {
  name          = "alias/rojopolis-key_${local.environment_slug}"
  target_key_id = aws_kms_key.rojopolis_key.key_id
}
