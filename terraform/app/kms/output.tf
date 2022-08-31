output "kms_key" {
  description = "KMS key"
  value       = "${aws_kms_alias.rojopolis_key_alias.name}"
}