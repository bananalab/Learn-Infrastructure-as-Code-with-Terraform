#Resources
# Objects managed by Terraform such as VMs or S3 Buckets.
# Declaring a Resource tells Terraform that it should CREATE
# and manage the resource described.  If the Resource already exists
# it must be imported into Terraform's state.
resource "aws_s3_bucket" "simple_bucket" {
}

# Resources accept configuration in the form of attributes.
# Each resource supports a unique set of attributes.  To understand a resource
# use the reference in the Terraform Registry: 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

# Terraform will return an object representing the resource including all the
# calculated values.

output "simple_bucket" {
  value = aws_s3_bucket.simple_bucket
}

#Data Sources
# Same as resources except they are not managed by Terraform.
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

#Dependency
# Resources can depend on one another.  Terraform will ensure that all
# dependencies are met before creating the resource.  Dependency can
# be implicit or explicit.
resource "aws_s3_bucket" "dependent_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-dependent-bucket"
  tags = {
    # Implicit dependency
    dependency = aws_s3_bucket.simple_bucket.arn
  }
}

resource "aws_s3_bucket" "chained_dependent_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-chained-dependent-bucket"
  # Explicit
  depends_on = [
    aws_s3_bucket.dependent_bucket
  ]
}
# Terraform creates a dependency graph when evaluating it's execution plan. 
# The graph can be visualized by running `terraform graph | dot -Tsvg > graph.svg`
# The dependency graph is a Directed Acyclical Graph (DAG) and can't 
# contain loops (cycles).
# The graph is processed in parallel when possible. The default concurrency is 10,
# but it can be changed.

resource "aws_s3_bucket" "independent_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-independent-bucket"
}
