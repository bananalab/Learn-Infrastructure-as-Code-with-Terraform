
data "aws_caller_identity" "current" {}

module "backend_s3_bucket" {
  source             = "github.com/bananalab/terraform-modules//modules/aws-s3-bucket?ref=v0.3.1"
  bucket             = "learn-terraform-${data.aws_caller_identity.current.account_id}"
  enable_replication = false
  logging_enabled    = false
}

resource "aws_dynamodb_table" "this" {
  name           = "learn-terraform-lock"
  billing_mode   = "PROVISIONED"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
