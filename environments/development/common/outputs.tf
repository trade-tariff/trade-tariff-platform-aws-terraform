output "secretsmanager_kms_key_arn" {
  description = "ARN of the key used to encrypt SecretsManager Secrets."
  value       = aws_kms_key.secretsmanager_kms_key.arn
}
