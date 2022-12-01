resource "aws_s3_bucket" "this" {
  bucket              = var.bucket
  bucket_prefix       = var.bucket_prefix
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
  lifecycle {
    precondition {
      condition     = !(var.bucket != null && var.bucket_prefix != null)
      error_message = "bucket and bucket_prefix cannot both be set."
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "this" {
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_logging" "this" {
  count                 = var.logging_enabled ? 1 : 0
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  target_bucket         = var.logging_target_bucket
  target_prefix         = var.logging_target_prefix
  lifecycle {
    precondition {
      condition     = var.logging_target_bucket != null
      error_message = "If logging is enabled logging_target_bucket must be set."
    }
    precondition {
      condition     = var.logging_target_prefix != null
      error_message = "If logging is enabled logging_target_prefix must be set."
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count                 = var.enable_server_side_encryption ? 1 : 0
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_master_key_id
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = var.replication_role
  token  = var.replication_token
  rule {
    status = "Enabled"
    destination {
      bucket        = var.replication_target_bucket
      storage_class = "STANDARD"
    }
  }
}
