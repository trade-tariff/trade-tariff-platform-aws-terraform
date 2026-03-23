output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN for use as API Gateway authorizer URI"
  value       = aws_lambda_function.this.invoke_arn
}

output "lambda_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}
