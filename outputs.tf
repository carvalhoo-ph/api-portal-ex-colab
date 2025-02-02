output "api_gateway_url" {
  value       = data.aws_api_gateway_rest_api.api.execution_arn
  description = "The execution ARN of the API Gateway"
}

output "api_invoke_url" {
  value       = "https://${data.aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/prod"
  description = "The URL of the API Gateway"
}
