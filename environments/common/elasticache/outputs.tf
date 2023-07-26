output "endpoint" {
  description = "Connection string of the cluster."
  value       = aws_elasticache_cluster.this.cache_nodes[0].address
}
