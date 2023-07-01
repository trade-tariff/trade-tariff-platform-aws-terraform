output "endpoint" {
  description = "Configuration endpoint of the replication group."
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}
