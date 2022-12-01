resource "null_resource" "example" {}

# Explicit dependency
# Same as resource or data_source
module "depends_on" {
  source     = "../01_minimal"
  parameter  = "test"
  depends_on = [null_resource.example]
}

# Count
module "count" {
  count     = 0
  source    = "../01_minimal"
  parameter = count.index
}

# For each
module "for_each" {
  for_each  = toset([for x in range(10) : tostring(x)])
  source    = "../01_minimal"
  parameter = each.value
}
