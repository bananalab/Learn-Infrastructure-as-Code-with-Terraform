output "rojopolis_rest_api_id" {
  description = "API Gateway resource"
  value       = "${aws_api_gateway_rest_api.rojopolis_api.id}"
}

output "rojopolis_rest_api_execution_arn" {
  description = "API Gateway execution arn"
  value       = "${aws_api_gateway_rest_api.rojopolis_api.execution_arn}"
}