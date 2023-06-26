resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.group_name
  description          = "Redis replica group for ${var.environment}."

  multi_az_enabled           = true
  automatic_failover_enabled = true
  apply_immediately          = var.apply_immediately

  engine         = "redis"
  engine_version = var.redis_version
  port           = 6739

  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.this.arn

  maintenance_window = var.maintenance_window
  snapshot_window    = var.snapshot_window

  num_cache_clusters = 2
  node_type          = var.instance_type

  security_group_names       = var.security_group_names
  transit_encryption_enabled = var.transit_encryption_enabled

  log_delivery_configuration {
    destination      = var.cloudwatch_log_group
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  # log_delivery_configuration {
  #   destination      = aws_kinesis_firehose_delivery_stream.example.name
  #   destination_type = "kinesis-firehose"
  #   log_format       = "json"
  #   log_type         = "engine-log"
  # }

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}

resource "aws_kms_key" "this" {
  description         = "KMS key for Redis on ${var.environment}."
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
}

resource "aws_elasticache_cluster" "replica" {
  count                = var.replicas
  cluster_id           = "replica-${count.index}"
  replication_group_id = aws_elasticache_replication_group.this.id
}
