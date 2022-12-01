# Providers can be embedded in modules, but this is to be avoided.
# Embedding provider configuration is tempting becuase it seems to provide
# an elegant level of abstration and encapsulation.

data "aws_regions" "current" {
  all_regions = true
}
/*
module "multi_region" {
  for_each  = aws_regions.current.names
  source    = "./module"
  parameter = 1
  region    = each.value
}
*/
module "west" {
  source    = "./module"
  parameter = 1
  region    = "us-west-1"
}

module "east" {
  source    = "./module"
  parameter = 1
  region    = "us-east-1"
}
