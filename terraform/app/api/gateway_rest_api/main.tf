terraform {
  required_version = ">= 0.11.8"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-api-rest-api"
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
  aws_account_id   = "${data.aws_caller_identity.current.account_id}"
  aws_region       = "${data.aws_region.current.name}"
  environment_slug = "${var.git_branch}"
}

data "terraform_remote_state" "lambda" {
  backend   = "s3"
  workspace = "${local.environment_slug}"
  config = {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-lambda"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
}

data "terraform_remote_state" "cognito_user_pool" {
  backend   = "s3"
  workspace = "${local.environment_slug}"
  config = {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-cognito-user-pool"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
}

data "template_file" "swagger_json" {
  template = "${file("${path.module}/../swagger.json")}"
  vars = {
    crud_handler_lambda_qualified_arn              = "${data.terraform_remote_state.lambda.outputs.crud_handler_lambda_qualified_arn}"
    rojopolis_user_pool_arn                        = "${data.terraform_remote_state.cognito_user_pool.outputs.rojopolis_user_pool_arn}"
    rojopolis_user_pool_resource_server_identifier = "${data.terraform_remote_state.cognito_user_pool.outputs.rojopolis_user_pool_resource_server_identifier}"
  }
}

resource "aws_api_gateway_rest_api" "rojopolis_api" {
  name        = "rojopolis API"
  description = "rojopolis API"
  body        = "${data.template_file.swagger_json.rendered}"
}