output "etl_queue_arn" {
  description = "ARN of SQS Queue"
  value       = "${aws_sqs_queue.etl_queue.arn}"
}

output "etl_queue_name" {
  description = "ARN of SQS Queue"
  value       = "${aws_sqs_queue.etl_queue.name}"
}