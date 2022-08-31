module "local-module" {
    source = "../"
    string_param = "foo"
}

output "module_output" {
    description = "The output from a module"
    value       = module.local-module.string_output
}
