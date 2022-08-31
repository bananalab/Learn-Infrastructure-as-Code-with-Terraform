terraform {
  required_version = ">= 0.11.8"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-api-sqs"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_region       = "${data.aws_region.current.name}"
  environment_slug = "${terraform.workspace}"
}

resource "aws_sqs_queue" "etl_queue" {
  name                       = "etl-queue-${local.environment_slug}"
  visibility_timeout_seconds = 300
}