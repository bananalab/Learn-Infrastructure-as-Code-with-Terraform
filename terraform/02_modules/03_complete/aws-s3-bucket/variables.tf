variable "bucket" {
  type        = string
  description = <<-EOT
    The name of the S3 bucket to create
  EOT
  default     = null
}

variable "bucket_prefix" {
  type        = string
  description = <<-EOT
    The prefix to use for the S3 bucket name
  EOT
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = <<-EOT
    Force destroy the bucket if it exists
  EOT
  default     = false
}

variable "object_lock_enabled" {
  type        = bool
  description = <<-EOT
    Enable object lock for the bucket
  EOT
  default     = false
}

variable "tags" {
  type        = map(any)
  description = <<-EOT
    Tags to apply to the bucket
  EOT
  default     = null
}
variable "block_public_acls" {
  type        = bool
  description = <<-EOT
    Block public access to the bucket
  EOT
  default     = true
}

variable "block_public_policy" {
  type        = bool
  description = <<-EOT
    Block public policy access to the bucket
  EOT
  default     = true
}

variable "ignore_public_acls" {
  type        = bool
  description = <<-EOT
    Ignore public acls for the bucket
  EOT
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  description = <<-EOT
    Restrict public access to the bucket
  EOT
  default     = true
}

variable "versioning_enabled" {
  type        = bool
  description = <<-EOT
    Enable versioning for the bucket
  EOT
  default     = true
}

variable "expected_bucket_owner" {
  type        = string
  description = <<-EOT
    The expected owner of the bucket
  EOT
  default     = null
}

variable "logging_enabled" {
  type        = bool
  description = <<-EOT
    Enable logging for the bucket
  EOT
  default     = true
}

variable "logging_target_bucket" {
  type        = string
  description = <<-EOT
    The target bucket for the logging configuration
  EOT
  default     = null
}
variable "logging_target_prefix" {
  type        = string
  description = <<-EOT
    The target prefix for the logging configuration
  EOT
  default     = null
}

variable "logging_target_grant" {
  type = list(object({
    grantee = optional(object({
      type          = string
      id            = optional(string)
      uri           = optional(string)
      email_address = optional(string)
    }))
    permission = optional(string)
  }))
  description = <<-EOT
    The target grant for the logging configuration
  EOT
  default     = null
}

variable "enable_server_side_encryption" {
  type        = bool
  description = <<-EOT
    Enable server side encryption for the bucket
  EOT
  default     = true
}

variable "kms_master_key_id" {
  type        = string
  description = <<-EOT
    The KMS key id to use for encryption
  EOT
  default     = null
}

variable "enable_replication" {
  type        = bool
  description = <<-EOT
    Enable replication for the bucket
  EOT
  default     = true
}

variable "replication_role" {
  type        = string
  description = <<-EOT
    The role ARN to use for replication
  EOT
  default     = null
}

variable "replication_target_bucket" {
  type        = string
  description = <<-EOT
    The target bucket to use for replication
  EOT
  default     = null
}

variable "replication_token" {
  type        = string
  description = <<-EOT
    The token to use for replication
  EOT
  default     = null
}
