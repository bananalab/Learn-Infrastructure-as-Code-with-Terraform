terraform {
  required_version = ">= 0.11.8"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-api-deployment"
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
  environment_slug = "${lower(terraform.workspace)}"
}

data "terraform_remote_state" "gateway_rest_api" {
  backend   = "s3"
  workspace = "default"
  config = {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-api-rest-api"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
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


resource "aws_api_gateway_deployment" "rojopolis_api_gateway_deployment" {
  rest_api_id       = "${data.terraform_remote_state.gateway_rest_api.outputs.rojopolis_rest_api_id}"
  description       = "${local.environment_slug}"
  stage_name        = "${local.environment_slug}"
  stage_description = "${local.environment_slug}"
  depends_on        = ["aws_lambda_permission.crud_handler_lambda_permission"]
}

resource "aws_lambda_permission" "crud_handler_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "${data.terraform_remote_state.lambda.outputs.crud_handler_lambda_arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${data.terraform_remote_state.gateway_rest_api.outputs.rojopolis_rest_api_execution_arn}/*/*/*"
}