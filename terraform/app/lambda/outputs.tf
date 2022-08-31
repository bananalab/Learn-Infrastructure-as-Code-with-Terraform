output "crud_handler_lambda_qualified_arn" {
  description = "Fully qualified ARN of CRUD handler Lambda"
  value       = "arn:aws:apigateway:${local.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.crud_handler.qualified_arn}/invocations"
}

output "crud_handler_lambda_arn" {
  description = "ARN of CRUD handler Lambda"
  value       = "${aws_lambda_function.crud_handler.qualified_arn}"
}

output "producerjobs_handler_lambda_arn" {
  description = "ARN of producerjobs handler Lambda"
  value       = "${aws_lambda_function.producerjobs_handler.qualified_arn}"
}

output "surveyjobs_handler_lambda_arn" {
  description = "ARN of surveyjobs handler Lambda"
  value       = "${aws_lambda_function.surveyjobs_handler.qualified_arn}"
}