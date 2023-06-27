resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.group_name
  description          = "Redis replica group for ${var.environment}."

  multi_az_enabled           = true
  automatic_failover_enabled = true
  apply_immediately          = var.apply_immediately

  engine               = "redis"
  engine_version       = var.redis_version
  port                 = 6739
  parameter_group_name = var.parameter_group

  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.this.arn

  maintenance_window = var.maintenance_window
  snapshot_window    = var.snapshot_window

  num_cache_clusters = 2
  node_type          = var.instance_type

  security_group_names       = var.security_group_names
  transit_encryption_enabled = var.transit_encryption_enabled

  # Logging requires Redis >=6.0 (SLOWLOG), and >=6.2 (engine log)
  # https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/Log_Delivery.html

  dynamic "log_delivery_configuration" {
    for_each = local.redis_major_version >= 6 && var.cloudwatch_log_group != null ? [1] : []
    content {
      destination      = var.cloudwatch_log_group
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "slow-log"
    }
  }

  dynamic "log_delivery_configuration" {
    for_each = local.redis_major_version >= 6 && local.redis_minor_version >= 2 && var.cloudwatch_log_group != null ? [1] : []
    content {
      destination      = var.cloudwatch_log_group
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "engine-log"
    }
  }

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
