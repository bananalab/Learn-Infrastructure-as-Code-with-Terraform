terraform {
  backend "s3" {
    bucket         = "learn-terraform-202151242785"
    dynamodb_table = "learn-terraform-lock"
    key            = "terraform.tfstate"
    region         = "us-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
