#Terraform type

# Configuration for the Terraform Engine.

terraform {
  required_version = "~>1.2.0"
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
  }
  # experiments = [example]
  #backend "remote" {
  #  organization = "example_corp"
  #
  #  workspaces {
  #    name = "my-app-prod"
  #  }
  #}
  #provider_meta "my-provider" {
  #  hello = "world"
  #}
}

#Provider type
# Implement cloud specific API and Terraform API.
# Provider configuation is specific to each provider.
# Providers expose Data Sources and Resources to Terraform.
provider "aws" {
  region = "us-east-1"
  alias  = "aws-us-east-1"
  #access_key = "my-access-key"
  #secret_key = "my-secret-key"

  # Providers may have aliases. Aliases are used when multiple instances
  # of a provider are required. 
  # Example: Resources span multiple regions.
  #
  # Limitations:
  #  * All instances of a provider must use the same version.
  #  * Providers aliases do not support expressions.
  #
  # Security Alert: Terraform configurations are normally shared via VCS
  #                 so secrets such as passwords and API keys should never
  #                 be stored in the configuration directly.
  #                 Many providers also accept partial configuration via 
  #                 environment variables or config files.  The AWS provider
  #                 will read the standard AWS CLI settings if they are present
}

# Version Constraint Syntax:
# * = (or no operator): Allows only one exact version number. Cannot be 
#     combined with other conditions.
# * !=: Excludes an exact version number.
# * >, >=, <, <=: Comparisons against a specified version, allowing versions
#                 for which the comparison is true. "Greater-than" requests 
#                 newer versions, and "less-than" requests older versions.
# * ~>: Allows only the rightmost version component to increment. For example,
#       to allow new patch releases within a specific minor release, use the full 
#       version number: ~> 1.0.4 will allow installation of 1.0.5 and 1.0.10 but 
#       not 1.1.0. This is usually called the pessimistic constraint operator.
