output "endpoint" {
  description = "Configuration endpoint of the replication group."
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "kms_key_arn" {
  description = "ARN of the KMS key used."
  value       = aws_kms_key.this.arn
}

output "kms_key_id" {
  description = "Key ID of the KMS key used."
  value       = aws_kms_key.this.key_id
}
