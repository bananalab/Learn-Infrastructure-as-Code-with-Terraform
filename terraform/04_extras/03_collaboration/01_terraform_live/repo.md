# Terraform Live.

We already created a Github repo for reusable modules, but what about root configs?

Root configs represent the single source of truth for your infrastructure.  The content of the HEAD of the default branch should always represent the desired state of the infrastructure.  One way to think of it: If the infrastructure doesn't match the default branch, then the infrastructure is wrong.  A `terraform apply` should always bring the infrastructure back to the desired state.  This is why it's important that no one is allowed to modify infrastructure with the AWS console in production accounts.

# Create a root config.

1. Create an empty repo called `terraform-live` in your Github account and clone it to your laptop.

2. Within the repo create a directory called `infra`.

3. Create the standard Terraform layout (`main.tf`, `variables.tf`, `outputs.tf` and `versions.tf`).

4. Add the Terraform code to create an s3 (hint: reuse the module you created in the previous excersise using it's Github path as the source.)