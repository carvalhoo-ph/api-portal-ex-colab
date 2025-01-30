output "api_url" {
  description = "The URL of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "api_invoke_url" {
  description = "The URL to invoke the API Gateway"
  value       = aws_api_gateway_rest_api.api.invoke_url
}
