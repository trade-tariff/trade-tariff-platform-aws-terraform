output "primary_endpoint" {
  description = "Connection string primary endpoint."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Connection string primary endpoint."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}
