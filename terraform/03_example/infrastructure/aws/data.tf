# Place common data sources in this file.

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "bananalab" {
  name = "bananalab.dev."
}

locals {
  app_host = "learn-terraform.${data.aws_route53_zone.bananalab.name}"
}
