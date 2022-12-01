# Backend for state

The Terraform state file is critical for managing infrastructure.  The state represents the state of the infrastructure as Terraform understands it.  If the state file is lost it can be complicated to recover (although it doesn't cause an immediate service impact).

Its also very important that multiple users have access to the state file if they will collaborate with Terraform. To enable this workflow Terraform supports remote backends.  Remote backends are cloud storage providers such as AWS s3.  There are many other backend providers but we'll focus on s3 in this excersize.

## Configure your account for remote state.

1. Begin with the `terraform-live` repo you created previously.

2. Add this code to the `versions.tf` file:

```
terraform {
    backend "s3" {
    bucket         = <name_of_bucket>
    key            = "terraform.tfstate"
    }
}
```
3. Run `terraform init`. (There will be a warning about migrating state).
4. Use the aws console to inspect the s3 bucket.  Verify that a state file exists there.

# State locking and S3.

It's very important that simultaneous writes do not happen to the state file.  Terraform enforces this with locks.  Most providers support native locking, but s3 does not.  To support locking add a dynamoDB table:

1. In the `main.tf` file, create a DynamoDB table:

    ```bash
    resource "aws_dynamodb_table" "terraform_lock" {
        name           = "terraform-lock-table"
        read_capacity  = 5
        write_capacity = 5
        hash_key       = "LockID"
        attribute {
            name = "LockID"
            type = "S"
        }
        tags = {
            "Name" = "State Lock Table"
        }
    }
2. Modify the `terraform/backend` block:
```
terraform {
    backend "s3" {
        bucket         = <name_of_bucket>
        key            = "terraform.tfstate"
        dynamodb_table = <name_of_table>
    }
}
```
2. Run `terraform-init`
3. In the AWS console inspect the DynamoDB table.  What do you see?