output "agencies_table_id" {
  description = "ID of agencies_table"
  value       = "${aws_dynamodb_table.agencies_table.id}"
}

output "producer_table_id" {
  description = "ID of producer table"
  value       = "${aws_dynamodb_table.producer_table.id}"
}
