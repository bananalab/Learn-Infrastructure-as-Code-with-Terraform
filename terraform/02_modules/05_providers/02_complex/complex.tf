# Sometimes mutiple instances of a provider are needed for the same module.
# Example:
#   Mutli region AWS

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.0"
      configuration_aliases = [aws.uswest1, aws.useast1]
    }
  }
}

provider "aws" {
  alias  = "uswest1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

module "multi_region" {
  providers = {
    aws.west = aws.uswest1
    aws.east = aws.useast1
  }
  source    = "./module"
  parameter = 1
}

# Drawbacks:
# * Complexity = Bad.
# * Breaks encapsulation.
# * "Code smell" (There is probably a better solution)
