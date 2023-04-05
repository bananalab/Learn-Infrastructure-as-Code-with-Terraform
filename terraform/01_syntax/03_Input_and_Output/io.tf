#Variables
# Variables are inputs to Terraform.
# Limitations:
#   * Immmutable.
#   * Don't support expressions.
# Can be specified on the command line with -var bucket_name=my-bucket
# or in files: terraform.tfvars or *.auto.tfvars
# or in environment variables: TF_VAR_bucket_name
variable "bucket_name" {
  # `type` is an optional data type specification
  type = string

  # `default` is the optional default value.  If `default` is ommited
  # then a value must be supplied.
  default = "bananalab-my-bucket"
}

# Locals can be used to apply expressions to variables:
locals {
  bucket_name_local = "my-company-${var.bucket_name}"
}

# Variables can also have complex types
variable "complex" {
  type = object({
    name = string
    aliases = optional(list(string), [])
  })
  description = <<-EOT
    A complex variable.
  EOT
  default = {
    name = "complex"
  }
}

# Validations
# Limitations:
#  * Validations can only refer to their own values.
variable "valid_bucket_name" {
  type    = string
  default = "bananalab-my-bucket"
  validation {
    condition     = can(regex("^bananalab-", var.valid_bucket_name))
    error_message = "Must begin with `bananalab-`."
  }
  # Multiple validation blocks are allowed.
  validation {
    condition     = length(var.valid_bucket_name) < 64
    error_message = "Must be less than 64 characters.  Got ${length(var.valid_bucket_name)}"
  }
}

#Outputs
# Outputs are printed by the CLI after `apply`.
# These can reveal calculated values.
# Also used in more advanced use cases: modules, remote_state data source
# Outputs can be retrieved at any time by running `terraform output`
output "bucket_info" {
  value = local.bucket_name_local
}

output "complex" {
  value = var.complex
}
