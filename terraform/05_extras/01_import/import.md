# Import resources

When adopting Terraform resources often already exist.  To import resources you can use the command `terraform import` however the terraform code that defines the infrastructure must already exist.

Challenge:
  Move the state file from the `multi_region` excersize to `terraform.tfstate`

Explore:
  Importing infrastructure is very tedious.  Tools exists to assist with the process. See if you can import your infrastructure with [Terraformer](https://github.com/GoogleCloudPlatform/terraformer).
