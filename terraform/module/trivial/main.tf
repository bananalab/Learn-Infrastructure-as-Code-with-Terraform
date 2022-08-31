variable "string_param" {
    type        = "string"
    description = "A string"
    default     = "biz"
}
output "string_output" {
    description = "The value of string_param"
    value       = var.string_param
}
