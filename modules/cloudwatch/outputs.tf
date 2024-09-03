output "log_group_name" {
  description = "Cloudwatch log group name."
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN of the log group."
  value       = aws_cloudwatch_log_group.this.arn
}
