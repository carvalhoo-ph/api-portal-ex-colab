output "api_invoke_url" {
  value       = "https://${local.api_id}.execute-api.${var.region}.amazonaws.com/prod"
  description = "The URL of the API Gateway"
}
