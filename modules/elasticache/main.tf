resource "aws_elasticache_replication_group" "this" {
  engine                      = var.engine
  engine_version              = var.engine_version
  port                        = var.port
  replication_group_id        = var.replication_group_id
  description                 = var.description
  parameter_group_name        = var.parameter_group_name
  num_node_groups             = var.num_node_groups
  replicas_per_node_group     = var.replicas_per_node_group
  node_type                   = var.node_type
  security_group_ids          = var.security_group_ids
  subnet_group_name           = local.subnet_group_name
  multi_az_enabled            = var.multi_az_enabled
  automatic_failover_enabled  = var.automatic_failover_enabled
  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_lg.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_lg.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  apply_immediately = var.apply_immediately
}

resource "aws_elasticache_subnet_group" "this" {
  count      = var.create_subnet_group ? 1 : 0
  name       = "${var.replication_group_id}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_cloudwatch_log_group" "slow_lg" {
  name              = "${var.replication_group_id}-slow-lg"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "engine_lg" {
  name              = "${var.replication_group_id}-engine-lg"
  retention_in_days = 30
}
