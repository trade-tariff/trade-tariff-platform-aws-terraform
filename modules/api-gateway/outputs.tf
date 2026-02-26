output "rest_api_id" {
  description = "ID of the API Gateway REST API."
  value       = aws_api_gateway_rest_api.this.id
}

output "stage_name" {
  description = "Name of the deployed stage."
  value       = aws_api_gateway_stage.this.stage_name
}

output "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage (for WAF association)."
  value       = aws_api_gateway_stage.this.arn
}

output "rest_api_name" {
  description = "Name of the API Gateway REST API."
  value       = aws_api_gateway_rest_api.this.name
}
