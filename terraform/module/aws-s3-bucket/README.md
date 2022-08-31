# aws-s3-bucket

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- This will become the header in README.md
     Add a description of the module here.
     Do not include Variable or Output descriptions. -->
L1 Module to create an S3 bucket.

## Example

```hcl
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
variable "logging_enabled" { default = true }
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
```
<!-- markdownlint-disable -->

## Modules

No modules.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>4 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Block public access to the bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Block public policy access to the bucket | `bool` | `true` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the S3 bucket to create | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | The prefix to use for the S3 bucket name | `string` | `null` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Enable replication for the bucket | `bool` | `true` | no |
| <a name="input_enable_server_side_encryption"></a> [enable\_server\_side\_encryption](#input\_enable\_server\_side\_encryption) | Enable server side encryption for the bucket | `bool` | `true` | no |
| <a name="input_expected_bucket_owner"></a> [expected\_bucket\_owner](#input\_expected\_bucket\_owner) | The expected owner of the bucket | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Force destroy the bucket if it exists | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Ignore public acls for the bucket | `bool` | `true` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The KMS key id to use for encryption | `string` | `null` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Enable logging for the bucket | `bool` | `true` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | The target bucket for the logging configuration | `string` | `null` | no |
| <a name="input_logging_target_grant"></a> [logging\_target\_grant](#input\_logging\_target\_grant) | The target grant for the logging configuration | <pre>list(object({<br>    grantee = optional(object({<br>      type          = string<br>      id            = optional(string)<br>      uri           = optional(string)<br>      email_address = optional(string)<br>    }))<br>    permission = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | The target prefix for the logging configuration | `string` | `null` | no |
| <a name="input_object_lock_enabled"></a> [object\_lock\_enabled](#input\_object\_lock\_enabled) | Enable object lock for the bucket | `bool` | `false` | no |
| <a name="input_replication_role"></a> [replication\_role](#input\_replication\_role) | The role ARN to use for replication | `string` | `null` | no |
| <a name="input_replication_target_bucket"></a> [replication\_target\_bucket](#input\_replication\_target\_bucket) | The target bucket to use for replication | `string` | `null` | no |
| <a name="input_replication_token"></a> [replication\_token](#input\_replication\_token) | The token to use for replication | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Restrict public access to the bucket | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the bucket | `map(any)` | `null` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning for the bucket | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_result"></a> [result](#output\_result) | The result of the module. |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
