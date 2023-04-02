# Dynamic blocks
# Some configurations can have multiple settings instances.
# These can be written with multiple config blocks with different settings.
resource "aws_s3_bucket" "bucket_static_blocks" {
  lifecycle_rule {
    prefix  = "/path1"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }
  lifecycle_rule {
    prefix  = "/path2"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
}


# This gets tedious and error prone when many similar blocks are required.
# Not DRY.
resource "aws_s3_bucket" "bucket_more_static_blocks" {
  lifecycle_rule {
    prefix  = "/path1"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }
  lifecycle_rule {
    prefix  = "/path2"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
  lifecycle_rule {
    prefix  = "/path3"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
  lifecycle_rule {
    prefix  = "/pathN"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }
}

# Dynamic blocks allow us to generate configuration from expressions.
resource "aws_s3_bucket" "bucket_dynamic_blocks" {
  dynamic "lifecycle_rule" {
    for_each = range(100)
    content {
      prefix  = "/path-${lifecycle_rule.key}"
      enabled = true
      noncurrent_version_expiration {
        days = 90
      }
    }
  }
}
