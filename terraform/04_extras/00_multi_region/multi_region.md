# Multi region resources

Often resources Terraform is used to manage resources in multiple regions.

Look at the example here: https://github.com/bananalab/terraform-modules/tree/main/modules/aws-rds-global-cluster

See that the module creates a database cluster spanning 2 regions.

Challenge:
  1. Clone the repo and see if you can fix any deploy and pre-commit errors.
  2. Can you make the cluster span 3 regions?
  3. Can you make the cluster span N number of regions?