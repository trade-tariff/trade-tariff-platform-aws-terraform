output "endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.this.reader_endpoint
}

output "rw_connection_string" {
  description = "Read/write connection string for use in applications."
  value       = local.rw_string
}

output "ro_connection_string" {
  description = "Read only connection string for use in applications."
  value       = local.ro_string
}
