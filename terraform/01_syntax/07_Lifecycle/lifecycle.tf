# Lifecycle blocks
# Meta-arguments
# * Are available on all resources. 

resource "aws_s3_bucket" "bucket_lifecycle" {
  lifecycle {
    create_before_destroy = false
    # By default Terraform will destroy a resource before creating a new one
    # when the resource must be replaced.
    prevent_destroy = false
    # A guardrail against inadvertant deletion.  Some cloud resources also have
    # a similar option built in:
    # Example:  
    #   aws_rds_cluster.deletion_protection
    # The Terraform option only prevents Terraform from deleting it, but the
    # resource attribute also protects from API and console deletion.
    ignore_changes = []
    # Sometimes resources are changed outside of Terraform under normal
    # circumstances.  Try to avoid it if possible, but if it's not possible
    # add those attributes to this list.
    replace_triggered_by = []
    # Terraform providers can specify changes that will reuire a resource to be
    # replaced with `ForceNew  true`, but sometimes recreation depends on 
    # relation to other resources. 
    # Example:
    #    Autoscaling target must be replaced when ECS service ID changes.
    precondition {
      # Precondition can validate any expression unless it causes a cycle.
      # This is a more robust way to validate inputs becuase it can use
      # more complex logic.
      condition     = !(var.bucket_name != null && var.bucket_prefix != null)
      error_message = "Only one of bucket_name or bucket_prefix may be specified."
    }
    postcondition {
      # Post condition can refer to itself.
      # Warning:
      #     Post conditions will create the resource prior to evaluation.
      #     If the check fails you won't be able to run the plan and fix the 
      #     problem.
      condition     = self.request_payer == "BucketOwner"
      error_message = "request_payer must be BucketOwner."
    }
  }
}

# Terraform documentation states:

#  Literal Values Only
#    The lifecycle settings all affect how Terraform constructs and traverses 
#    the dependency graph. As a result, only literal values can be used because
#    the processing happens too early for arbitrary expression evaluation.

# This is incorrect and only applies to:
#  * create_before_destroy
#  * prevent_destroy
#  * ignore_changes
#  * replace_triggered_by
