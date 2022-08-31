# Terraform HCL
data "null_data_source" "example" { inputs = null }
# type = data
# lablel = null_data_source
# label = example
# { inputs = null } = body

# Expressions
# used to refer to or compute values within a configuration.

# Local Values
# allow you to assign a name to an expression.
# Locals can make your code more readable by eliminating duplicate code (DRY).
locals {
  a_local = "Terraform"
}
# There may be multiple locals blocks, but the namespace is global.


#Interpolation
# Substitute values in strings.
locals {
  another_local = "${local.a_local} is fun."
}

#Data types
# Terraform supports simple and complex data types
locals {
  a_string  = "This is a string."
  a_number  = 3.1415
  a_boolean = true
  a_list = [
    "element1",
    2,
    "three"
  ]
  a_map = {
    key = "value"
  }

  # Complex
  person = {
    name = "Robert Jordan",
    phone_numbers = {
      home   = "415-444-1212",
      mobile = "415-555-1313"
    },
    active = false,
    age    = 32
  }
}

#Operators
# Terraform supports arithmetic and logical operations in expressions too
locals {
  //Arithmetic
  three = 1 + 2 // addition
  two   = 3 - 1 // subtraction
  one   = 2 / 2 // division
  zero  = 1 * 0 // multiplication

  //Logical
  t = true || false // OR true if either value is true
  f = true && false // AND true if both values are true

  //Comparison
  gt  = 2 > 1  // true if right value is greater
  gte = 2 >= 1 // true if right value is greater or equal
  lt  = 1 < 2  // true if left value is greater
  lte = 1 <= 2 // true if left value is greate or equal
  eq  = 1 == 1 // true if left and right are equal
  neq = 1 != 2 // true if left and right are not equal
}

# References
locals {
  a_ref = data.null_data_source.example.random
}

#Conditionals
locals {
  is_null = data.null_data_source.example.random == null ? true : false
}

#Functions
# Terraform has 100+ built in functions (but no ability to define custom functions!)
# https://www.terraform.io/docs/configuration/functions.html
# The syntax for a function call is <function_name>(<arg1>, <arg2>).
locals {
  //Date and Time
  ts            = timestamp() //Returns the current date and time.
  current_month = formatdate("MMMM", local.ts)
  tomorrow      = formatdate("DD", timeadd(local.ts, "24h"))
}

locals {
  //String
  lcase          = lower("A mixed case String")
  ucase          = upper("a lower case string")
  trimmed        = trimspace(" A string with leading and trailing spaces    ")
  formatted      = format("Hello %s", "World")
  formatted_list = formatlist("Hello %s", ["John", "Paul", "George", "Ringo"])
}

#Iteration
# HCL has a `for` syntax for iterating over list values.
# 
locals {
  l          = ["one", "two", "three"]
  upper_list = [for item in local.l : upper(item)]
  upper_map  = { for item in local.l : item => upper(item) }
}

#Filtering
# The `for` syntax can also filter with the `if` clause.
locals {
  n     = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  evens = [for i in local.n : i if i % 2 == 0]
}

#Directives and Heredocs
# HCL supports more complex string templating that can be used to generate
# full descriptive paragraphs too.
output "heredoc" {
  value = <<-EOT
    This is called a `heredoc`.  It's a string literal
    that can span multiple lines.
  EOT
}

output "directive" {
  value = <<-EOT
    This is a `heredoc` with directives.
    %{if local.person.name == ""}
    Sorry, I don't know your name.
    %{else}
    Hi ${local.person.name}
    %{endif}
  EOT
}

#Terraform
# Optional configuration for the Terraform Engine.
# Version Constraint Syntax:
# * = (or no operator): Allows only one exact version number. Cannot be 
#     combined with other conditions.
# * !=: Excludes an exact version number.
# * >, >=, <, <=: Comparisons against a specified version, allowing versions
#                 for which the comparison is true. "Greater-than" requests 
#                 newer versions, and "less-than" requests older versions.
# * ~>: Allows only the rightmost version component to increment. For example,
#       to allow new patch releases within a specific minor release, use the full 
#       version number: ~> 1.0.4 will allow installation of 1.0.5 and 1.0.10 but 
#       not 1.1.0. This is usually called the pessimistic constraint operator.
terraform {
  required_version = "~>1.2.0"
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
  }
  # experiments = [example]
  #backend "remote" {
  #  organization = "example_corp"
  #
  #  workspaces {
  #    name = "my-app-prod"
  #  }
  #}
  #provider_meta "my-provider" {
  #  hello = "world"
  #}
}


#Provider
# Implement cloud specific API and Terraform API.
# Provider configuation is specific to each provider.
# Providers expose Data Sources and Resources to Terraform.
provider "aws" {
  region = "us-east-1"
  #access_key = "my-access-key"
  #secret_key = "my-secret-key"

  # Many providers also accept partial configuration via environment variables
  # or config files.  The AWS provider will read the standard AWS CLI
  # settings if they are present.
}



#Data Sources
# Objects NOT managed by Terraform.
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

#Resources
# Objects managed by Terraform such as VMs or S3 Buckets.
# Declaring a Resource tells Terraform that it should CREATE
# and manage the Resource described.  If the Resource already exists
# it must be imported into Terraform's state.
resource "aws_s3_bucket" "simple_bucket" {
}

#Outputs
# Outputs are printed by the CLI after `apply`.
# These can reveal calculated values.
# Also used in more advanced use cases: modules, remote_state
# Outputs can be retrieved at any time by running `terraform output`
output "bucket_info" {
  value = aws_s3_bucket.simple_bucket
}

# The path for data objects is prefixed with data.
output "aws_caller_info" {
  value = data.aws_caller_identity.current
}


#Dependency
# Resources can depend on one another.  Terraform will ensure that all
# dependencies are met before creating the resource.  Dependency can
# be implicit or explicit.
resource "aws_s3_bucket" "dependent_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-dependent_bucket"
  tags = {
    # Implicit dependency
    dependency = aws_s3_bucket.simple_bucket.arn
  }
}

resource "aws_s3_bucket" "chained_dependent_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-chained_dependent_bucket"
  # Explicit
  depends_on = [
    aws_s3_bucket.dependent_bucket
  ]
}
# Terraform creates a dependency graph when evaluating it's execution plan. 
# The graph can be visualized by running `terraform graph | dot -Tsvg > graph.svg`
# The dependency graph is a Directed Acyclical Graph (DAG) and can't 
# contain loops (cycles).
# The graph is processed in parallel when possible.  The default concurrency is 10,
# but it can be changed.

resource "aws_s3_bucket" "independent_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-independent_bucket"
}

#Count
# All resources have a `count` meta-parameter.
# If count is set then a list of resources is returned (even if there is only 1)
# If `count` is set then a `count.index` value is available.  This value contains
# the current iteration number.
# TIP: setting `count = 0` is a handy way to remove a resource but keep the config.
resource "aws_s3_bucket" "count_buckets" {
  count  = 0
  bucket = "${data.aws_caller_identity.current.account_id}-bucket${count.index}"
}

#For Each
# All resources may have a `for_each` meta parameter.
# you can use for_each to iterate over any iterable item (list, set, map, or object).
# An empty iterator won't create any resource.
resource "aws_s3_bucket" "each_buckets" {
  for_each = {
    "${data.aws_caller_identity.current.account_id}-${data.null_data_source.example.random}" = "My Bucket"
  }
  bucket = each.key
  tags = {
    description = each.value
  }
}

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

resource "aws_s3_bucket" "bucket_dynamic_blocks" {
  dynamic "lifecycle_rule" {
    for_each = range(10)
    content {
      prefix  = "/path${lifecycle_rule.value}"
      enabled = true
      noncurrent_version_expiration {
        days = 90
      }
    }
  }
}

#Variables
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
resource "aws_s3_bucket" "simple_bucket_name" {
  bucket = var.bucket_name
}
# Variables can also have complex types
variable "complex" {
  type = object({
    name = string
    //aliases = optional(list(string), []) available as experimental feature. GA in 1.3.0
  })
  description = <<-EOT
    A complex variable.
  EOT
  default = {
    name = "complex"
  }
}

# Validations
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
resource "aws_s3_bucket" "bucket_validated_input" {
  bucket = var.valid_bucket_name
}
# Variable validations can only refer to their own values.
# More complex validations can be achieved with precondition
# and postcondition blocks on resources

resource "aws_s3_bucket" "bucket_validated_conditions" {
  lifecycle {
    precondition {
      # Precondition can validate any expression unless it causes a cycle.
      condition     = length(var.valid_bucket_name) < 64 && length(var.bucket_name) < 64
      error_message = "valid_bucket_name and bucket_name must both be less than 64 characters."
    }
    postcondition {
      # Post condition can refer to itself.
      condition     = self.request_payer == "BucketOwner"
      error_message = "request_payer must be BucketOwner"
    }
  }
}

# Lifecycle blocks
resource "aws_s3_bucket" "bucket_lifecycle" {
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
    ignore_changes        = []
    replace_triggered_by  = []
  }
}

# Provisioner blocks
# use provisioners as a last resort.
resource "aws_s3_bucket" "bucket_provisioner" {
  provisioner "local-exec" {
    command = "mkdir -p ${self.bucket}"
    #interpreter = ["/bin/bash", "-c"]
    #working_dir = "~"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.bucket}"
  }
}

# Refactoring can achived with the moved block or with
# `terraform state mv`
#moved {
#  from = aws_s3_bucket.bucket_provisioner
#  to   = aws_s3_bucket.moved_bucket_provisioner
#}
