output "db_arn" {
  description = "ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "Connection endpoint for the RDS instance. Format: `address:port`."
  value       = aws_db_instance.this.endpoint
}

output "kms_key_arn" {
  description = "ARN of the KMS Key created to encrypt database performance insights data."
  value       = aws_kms_key.this.arn
}

output "kms_key_id" {
  description = "Globally unique ID of the KMS Key created to encrypt database performance insights data."
  value       = aws_kms_key.this.key_id
}
