output "endpoint" {
  description = "Configuration endpoint of the replication group."
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "replication_group_arn" {
  description = "ARN of the replication group."
  value       = aws_elasticache_replication_group.this.arn
}
