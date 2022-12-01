output "result" {
  description = <<-EOT
      The result of the module.
    EOT
  value       = aws_s3_bucket.this
}
