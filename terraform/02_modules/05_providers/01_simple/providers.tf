# Sometimes mutiple instances of a provider are needed.
# Example:
#   Mutli region AWS
provider "aws" {
  alias  = "uswest1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

module "west" {
  providers = {
    aws = aws.uswest1
  }
  source    = "../../01_minimal"
  parameter = 1
}

module "east" {
  providers = {
    aws = aws.useast1
  }
  source    = "../../01_minimal"
  parameter = 2
}

/* This won't work, unfortunately.
module "for_each" {
  for_each = [useast1, uswest1]
  providers = {
    aws = "aws.${each.value}"
  }
  source    = "../../01_minimal"
  parameter = 3
}
*/
