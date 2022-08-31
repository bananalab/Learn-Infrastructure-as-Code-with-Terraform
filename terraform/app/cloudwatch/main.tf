terraform {
  required_version = ">= 0.11.8"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-cloudwatch"
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
  environment_slug = "${terraform.workspace}"
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

resource "aws_cloudwatch_event_rule" "producer_timer" {
  name                = "producer-timer-${local.environment_slug}"
  description         = "Execute producer Lambda"
  schedule_expression = "rate(${var.poll_interval} minutes)"
}

resource "aws_cloudwatch_event_target" "producer_target" {
  rule = "${aws_cloudwatch_event_rule.producer_timer.name}"
  arn  = "${data.terraform_remote_state.lambda.outputs.producerjobs_handler_lambda_arn}"
}

resource "aws_lambda_permission" "producerjobs_handler_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "${data.terraform_remote_state.lambda.outputs.producerjobs_handler_lambda_arn}"
  principal     = "events.amazonaws.com"

  source_arn = "arn:aws:events:${local.aws_region}:${local.aws_account_id}:rule/*"
}