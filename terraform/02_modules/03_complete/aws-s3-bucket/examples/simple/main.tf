/**
  * Examples should illustrate typical use cases.
  * For multiple examples each should have its own directory.
  *
  * > Running module examples uses a local state file.
  * > If you delete the .terraform directory the resources
  * > will be orphaned.
*/

variable "bucket" { default = null }
variable "bucket_prefix" { default = null }
variable "force_destroy" { default = false }
variable "object_lock_enabled" { default = false }
variable "tags" { default = null }
variable "block_public_acls" { default = true }
variable "block_public_policy" { default = true }
variable "ignore_public_acls" { default = true }
variable "restrict_public_buckets" { default = true }
variable "versioning_enabled" { default = true }
variable "expected_bucket_owner" { default = null }
variable "logging_enabled" { default = false }
variable "logging_target_bucket" { default = null }
variable "logging_target_prefix" { default = null }
variable "logging_target_grant" { default = null }
variable "enable_server_side_encryption" { default = true }
variable "kms_master_key_id" { default = null }
variable "enable_replication" { default = false }
variable "replication_role" { default = null }
variable "replication_target_bucket" { default = null }



module "this" {
  source                        = "../../"
  bucket                        = var.bucket
  bucket_prefix                 = var.bucket_prefix
  force_destroy                 = var.force_destroy
  object_lock_enabled           = var.object_lock_enabled
  tags                          = var.tags
  block_public_acls             = var.block_public_acls
  block_public_policy           = var.block_public_policy
  ignore_public_acls            = var.ignore_public_acls
  versioning_enabled            = var.versioning_enabled
  logging_enabled               = var.logging_enabled
  logging_target_bucket         = var.logging_target_bucket
  logging_target_prefix         = var.logging_target_prefix
  logging_target_grant          = var.logging_target_grant
  expected_bucket_owner         = var.expected_bucket_owner
  restrict_public_buckets       = var.restrict_public_buckets
  enable_server_side_encryption = var.enable_server_side_encryption
  kms_master_key_id             = var.kms_master_key_id
  enable_replication            = var.enable_replication
  replication_role              = var.replication_role
  replication_target_bucket     = var.replication_target_bucket
}

output "result" {
  description = <<-EOT
    The result of the module.
  EOT
  value       = module.this.result
}
