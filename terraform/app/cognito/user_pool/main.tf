terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket         = "rojopolis-tf"
    key            = "rojopolis-cognito-user-pool"
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
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name
}

resource "aws_cognito_user_pool" "rojopolis_user_pool" {
  name = "rojopolis User Pool"
  schema {
    name                = "orgIds"
    attribute_data_type = "String"
    mutable             = "true"
    string_attribute_constraints {
      min_length = "0"
      max_length = "2048"
    }
  }
}

resource "aws_cognito_user_pool_client" "rojopolis_user_pool_client" {
  name                = "rojopolis App Client"
  user_pool_id        = "${aws_cognito_user_pool.rojopolis_user_pool.id}"
  allowed_oauth_flows = ["implicit", "code"]
  explicit_auth_flows = ["USER_PASSWORD_AUTH"]
  allowed_oauth_scopes = concat([
    "openid",
    "phone",
    "email",
    "profile",
    "aws.cognito.signin.user.admin"],
    aws_cognito_resource_server.rojopolis_user_pool_resource_server.scope_identifiers
  )
  callback_urls = [
    "https://staging.textrojopolis.com",
    "https://secure.textrojopolis.com",
  "http://localhost:6075"]
  logout_urls                          = ["https://localhost:6075"] # TODO: change this
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = "true"
}

resource "aws_cognito_user_pool_domain" "rojopolis_user_pool_domain" {
  domain       = "rojopolis-${local.aws_account_id}"
  user_pool_id = "${aws_cognito_user_pool.rojopolis_user_pool.id}"
}

resource "aws_cognito_resource_server" "rojopolis_user_pool_resource_server" {
  identifier = "https://api.rojopolis.com"
  name       = "My 90 API"


  scope {
    scope_name        = "agency.read"
    scope_description = "Users can read agency resources"
  }
  scope {
    scope_name        = "questionResponses.read"
    scope_description = "Users can read questionResponses resources"
  } /*
    {
      scope_name        = "questions.read"
      scope_description = "Users can read questions resources"
    },
    {
      scope_name        = "responsesSentimentMetadata.read"
      scope_description = "Users can read responsesSentimentMetadatare sources"
    },
    {
      scope_name        = "topics.read"
      scope_description = "Users can read topics resources"
    },
    {
      scope_name        = "responses.read"
      scope_description = "Users can read responses resources"
    },
    {
      scope_name        = "responsesMetadata.read"
      scope_description = "Users can read responses resources"
    },
    {
      scope_name        = "questionResponsesMetadata.read"
      scope_description = "Users can read responses resources"
    },
    {
      scope_name        = "questionChoices.read"
      scope_description = "Users can read question choices resources"
    },
  ]*/

  user_pool_id = "${aws_cognito_user_pool.rojopolis_user_pool.id}"
}
