terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-lambda"
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
  aws_account_id   = data.aws_caller_identity.current.account_id
  aws_region       = data.aws_region.current.name
  lambda_base_dir  = "${path.module}/functions"
  environment_slug = "${lower(terraform.workspace)}"
}

data "terraform_remote_state" "dynamodb" {
  backend   = "s3"
  workspace = local.environment_slug
  config = {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-dynamodb"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
}

data "terraform_remote_state" "sqs" {
  backend   = "s3"
  workspace = local.environment_slug
  config = {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-api-sqs"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
}

data "terraform_remote_state" "kms" {
  backend   = "s3"
  workspace = local.environment_slug
  config = {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-kms"
    region         = "us-east-1"
    dynamodb_table = "rojopolis-terraform-lock"
  }
}

resource "aws_s3_bucket" "rojopolis_lambda_bucket" {
  bucket = "rojopolis-lambda-${local.aws_region}-${local.aws_account_id}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

#-------------------------------------------------------------------------------
#-- CRUD Handler
#-------------------------------------------------------------------------------
data "template_file" "lambda_role_policy_template" {
  template = "${file("${path.module}/lambda_role_policy.tpl")}"
  vars = {
    aws_account_id = "${local.aws_account_id}"
    aws_region     = "${local.aws_region}"
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "lambda_role_policy"
  role = "${aws_iam_role.crud_lambda_role.id}"

  policy = "${data.template_file.lambda_role_policy_template.rendered}"
}

resource "aws_iam_role" "crud_lambda_role" {
  name               = "crud_lambda_role-${local.environment_slug}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

module "crud_handler_archive" {
  source      = "rojopolis/lambda-python-archive/aws"
  version     = "0.1.4"
  src_dir     = "${local.lambda_base_dir}/crud_handler"
  output_path = "${path.module}/artifacts/crud_handler.zip"
}

resource "aws_s3_bucket_object" "crud_handler_archive_object" {
  bucket = "${aws_s3_bucket.rojopolis_lambda_bucket.id}"
  key    = "crud_handler.zip"
  source = "${module.crud_handler_archive.archive_path}"
  etag   = filemd5(module.crud_handler_archive.archive_path)
}

resource "aws_lambda_function" "crud_handler" {
  s3_bucket         = "${aws_s3_bucket.rojopolis_lambda_bucket.id}"
  s3_key            = "${aws_s3_bucket_object.crud_handler_archive_object.id}"
  s3_object_version = "${aws_s3_bucket_object.crud_handler_archive_object.version_id}"
  function_name     = "crud_handler-${local.environment_slug}"
  role              = "${aws_iam_role.crud_lambda_role.arn}"
  handler           = "app.entrypoint"
  source_code_hash  = "${module.crud_handler_archive.source_code_hash}"
  runtime           = "python3.6"
  publish           = true
  environment {
    variables = {
      AGENCY_TABLE_ID = data.terraform_remote_state.dynamodb.outputs.agencies_table_id
    }
  }
}

#-------------------------------------------------------------------------------
#-- SurveyJobs
#-------------------------------------------------------------------------------
resource "aws_s3_bucket" "rojopolis_survey_bucket" {
  bucket = "rojopolis-survey-${local.aws_region}-${local.aws_account_id}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

module "surveyjobs_handler_archive" {
  source      = "rojopolis/lambda-python-archive/aws"
  version     = "0.1.4"
  src_dir     = "${local.lambda_base_dir}/surveyjobs"
  output_path = "${path.module}/artifacts/surveyjobs.zip"
}

resource "aws_s3_bucket_object" "surveyjobs_handler_archive_object" {
  bucket = "${aws_s3_bucket.rojopolis_lambda_bucket.id}"
  key    = "surveyjobs.zip"
  source = "${module.surveyjobs_handler_archive.archive_path}"
  etag   = filemd5(module.surveyjobs_handler_archive.archive_path)
}

resource "aws_lambda_function" "surveyjobs_handler" {
  s3_bucket         = "${aws_s3_bucket.rojopolis_lambda_bucket.id}"
  s3_key            = "${aws_s3_bucket_object.surveyjobs_handler_archive_object.id}"
  s3_object_version = "${aws_s3_bucket_object.surveyjobs_handler_archive_object.version_id}"
  function_name     = "surveyjobs-${local.environment_slug}"
  role              = "${aws_iam_role.surveyjobs_lambda_role.arn}"
  handler           = "qualtrics.entrypoint"
  source_code_hash  = "${module.surveyjobs_handler_archive.source_code_hash}"
  runtime           = "python3.6"
  publish           = true
  timeout           = 300
  environment {
    variables = {
      S3_BUCKET         = "${aws_s3_bucket.rojopolis_survey_bucket.id}"
      X_API_TOKEN       = "${var.qualtrics_api_key}"
      AGENCIES_TABLE_ID = "${data.terraform_remote_state.dynamodb.outputs.agencies_table_id}"
      KMS_KEY           = "${data.terraform_remote_state.kms.outputs.kms_key}"
    }
  }
}

resource "aws_iam_role_policy" "surveyjobs_role_policy" {
  name = "lambda_role_policy"
  role = "${aws_iam_role.surveyjobs_lambda_role.id}"

  policy = "${data.template_file.lambda_role_policy_template.rendered}"
}

resource "aws_iam_role" "surveyjobs_lambda_role" {
  name               = "surveyjobs_lambda_role-${local.environment_slug}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_event_source_mapping" "etl_event_source_mapping" {
  event_source_arn = "${data.terraform_remote_state.sqs.outputs.etl_queue_arn}"
  function_name    = "${aws_lambda_function.surveyjobs_handler.qualified_arn}"
}

#-------------------------------------------------------------------------------
#-- ProducerJobs 
#-------------------------------------------------------------------------------
module "producerjobs_handler_archive" {
  source      = "rojopolis/lambda-python-archive/aws"
  version     = "0.1.4"
  src_dir     = "${local.lambda_base_dir}/producerjobs"
  output_path = "${path.module}/artifacts/producerjobs.zip"
}

resource "aws_s3_bucket_object" "producerjobs_handler_archive_object" {
  bucket = "${aws_s3_bucket.rojopolis_lambda_bucket.id}"
  key    = "producerjobs.zip"
  source = "${module.producerjobs_handler_archive.archive_path}"
  etag   = filemd5(module.producerjobs_handler_archive.archive_path)
}

resource "aws_lambda_function" "producerjobs_handler" {
  s3_bucket         = "${aws_s3_bucket.rojopolis_lambda_bucket.id}"
  s3_key            = "${aws_s3_bucket_object.producerjobs_handler_archive_object.id}"
  s3_object_version = "${aws_s3_bucket_object.producerjobs_handler_archive_object.version_id}"
  function_name     = "producerjobs-${local.environment_slug}"
  role              = "${aws_iam_role.producerjobs_lambda_role.arn}"
  handler           = "dyno2sqs.entrypoint"
  source_code_hash  = "${module.producerjobs_handler_archive.source_code_hash}"
  runtime           = "python3.6"
  publish           = true
  environment {
    variables = {
      PRODUCER_JOB_QUEUE = "${data.terraform_remote_state.sqs.outputs.etl_queue_name}"
      PRODUCER_JOB_TABLE = "${data.terraform_remote_state.dynamodb.outputs.producer_table_id}"
    }
  }
}

resource "aws_iam_role_policy" "producerjobs_role_policy" {
  name = "lambda_role_policy"
  role = "${aws_iam_role.producerjobs_lambda_role.id}"

  policy = "${data.template_file.lambda_role_policy_template.rendered}"
}

resource "aws_iam_role" "producerjobs_lambda_role" {
  name               = "producerjobs_lambda_role-${local.environment_slug}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}