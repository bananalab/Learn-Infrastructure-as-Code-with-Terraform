# The root module (aka config) refers to a module similar to the
# resource syntax, but not exactly the same.

module "minimal" {
  source    = "../01_minimal"
  parameter = "test"
}

output "result" {
  value = module.minimal.result
}
