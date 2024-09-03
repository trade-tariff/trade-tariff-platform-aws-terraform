output "secret_arn" {
  description = "ARN of the secret to be used in IAM policies."
  value       = aws_secretsmanager_secret.this.arn
}
