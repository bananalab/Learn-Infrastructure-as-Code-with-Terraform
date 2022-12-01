terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.0"
      configuration_aliases = [aws.west, aws.east]
    }
  }
}

resource "aws_s3_bucket" "west" {
  provider = aws.west
}

resource "aws_s3_bucket" "east" {
  provider = aws.east
}
