### Terraform module for elasticache redis cluster

resource "aws_elasticache_replication_group" "this" {
  engine                      = "redis"
  port                        = var.port
  replication_group_id        = var.replication_group_id
  description                 = var.description
  parameter_group_name        = var.parameter_group_name
  num_node_groups             = var.num_node_groups
  replicas_per_node_group     = var.replicas_per_node_group
  node_type                   = var.node_type
  security_group_ids          = var.security_group_ids
  subnet_group_name           = var.subnet_group_name
  multi_az_enabled            = var.multi_az_enabled
  automatic_failover_enabled  = var.automatic_failover_enabled
  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration

    content {
      destination_type = log_delivery_configuration.value.destination_type
      destination      = log_delivery_configuration.value.destination
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  apply_immediately = var.apply_immediately
  tags              = local.tags
}
