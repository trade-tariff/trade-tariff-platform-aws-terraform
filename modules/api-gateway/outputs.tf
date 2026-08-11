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

output "execution_arn" {
  description = "Execution ARN of the API Gateway REST API."
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "access_log_group_name" {
  description = "Name of the CloudWatch log group receiving API Gateway access logs (null unless access_logging_enabled)."
  value       = try(aws_cloudwatch_log_group.access_logs[0].name, null)
}
