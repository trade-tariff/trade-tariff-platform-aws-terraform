resource "aws_elasticache_cluster" "this" {
  cluster_id        = var.group_name
  apply_immediately = var.apply_immediately

  engine               = "redis"
  engine_version       = var.redis_version
  port                 = 6739
  parameter_group_name = var.parameter_group
  num_cache_nodes      = 1

  maintenance_window       = var.maintenance_window
  snapshot_window          = var.snapshot_window
  snapshot_retention_limit = var.snapshot_retention_limit
  node_type                = var.instance_type

  security_group_ids = var.security_group_ids
  subnet_group_name  = var.subnet_group_name
  network_type       = "ipv4"

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
}
