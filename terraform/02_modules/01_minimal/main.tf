resource "null_resource" "example" {
  triggers = {
    trigger = var.parameter
  }
}
