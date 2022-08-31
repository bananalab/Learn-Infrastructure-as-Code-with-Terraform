output "rojopolis_user_pool_arn" {
  description = "Cognito User Pool resource"
  value       = "${aws_cognito_user_pool.rojopolis_user_pool.arn}"
}

output "rojopolis_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = "${aws_cognito_user_pool_client.rojopolis_user_pool_client.id}"
}

output "rojopolis_user_pool_resource_server_identifier" {
  description = "Cognito User Pool Client ID"
  value       = "${aws_cognito_resource_server.rojopolis_user_pool_resource_server.identifier}"
}