locals {
  valkey = {
    "frontend"   = "cache.t3.micro",
    "backend-uk" = "cache.t3.micro",
    "backend-xi" = "cache.t3.micro",
    "sidekiq-uk" = "cache.t3.micro",
    "sidekiq-xi" = "cache.t3.micro",
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "redis-subnet-group"
  subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids
}

resource "aws_elasticache_parameter_group" "sidekiq" {
  name   = "valkey9-noeviction"
  family = "valkey9"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Authenticated, encrypted clusters
module "valkey" {
  source   = "../../../modules/elasticache/"
  for_each = local.valkey

  engine         = "valkey"
  engine_version = "9.0"

  replication_group_id        = "valkey-${each.key}-${var.environment}"
  description                 = "valkey-${each.key}-${var.environment}"
  parameter_group_name        = strcontains(each.key, "sidekiq") ? aws_elasticache_parameter_group.sidekiq.name : "default.valkey9"
  num_node_groups             = 1
  replicas_per_node_group     = 2
  node_type                   = each.value
  security_group_ids          = [module.alb-security-group.redis_security_group_id]
  subnet_group_name           = aws_elasticache_subnet_group.this.name
  multi_az_enabled            = true
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  auto_minor_version_upgrade  = true
  maintenance_window          = "sun:04:00-sun:05:00"
  snapshot_window             = "02:00-04:00"
  snapshot_retention_limit    = 7
  apply_immediately           = true
  log_retention_days          = 14

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"
  auth_token                 = random_password.valkey_auth[each.key].result
  auth_token_update_strategy = "ROTATE"
}

# Generate a password for each cluster, to avoid credential sharing
resource "random_password" "valkey_auth" {
  for_each = local.valkey
  length   = 16
  special  = false
}

resource "aws_secretsmanager_secret" "valkey_connection_string" {
  for_each   = local.valkey
  name       = "valkey-${each.key}-connection-string"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "valkey_connection_string_value" {
  for_each      = local.valkey
  secret_id     = aws_secretsmanager_secret.valkey_connection_string[each.key].id
  secret_string = "rediss://:${random_password.valkey_auth[each.key].result}@${module.valkey[each.key].primary_endpoint}:6379"
}

locals {
  # There are three nodes in each cluster; therefore we want three metrics for
  # each graph, to group the nodes
  cluster_nodes = range(1, 4)

  memory_use_widgets = [
    for k, v in local.valkey : {
      type   = "metric"
      width  = 8
      height = 4
      properties = {
        metrics = [
          [
            "AWS/ElastiCache",
            "DatabaseMemoryUsageCountedForEvictPercentage",
            "ReplicationGroupId",
            "valkey-${k}-${var.environment}"
          ]
        ]
        period = 3600
        stat   = "Average"
        region = var.region
        title  = "Valkey ${title(split("-", k)[0])}${length(split("-", k)) > 1 ? " ${upper(split("-", k)[1])}" : ""} Memory Usage"
      }
    }
  ]

  key_count_widgets = [
    for k, v in local.valkey : {
      type   = "metric"
      width  = 8
      height = 4
      properties = {
        metrics = [
          for i in local.cluster_nodes : [
            "AWS/ElastiCache",
            "CurrVolatileItems", # Cache items with a TTL set
            "CacheClusterId",
            "valkey-${k}-${var.environment}-00${i}"
          ]
        ]
        period = 3600
        stat   = "Average"
        region = var.region
        title  = "Valkey ${title(split("-", k)[0])}${length(split("-", k)) > 1 ? " ${upper(split("-", k)[1])}" : ""} Key Count"
      }
    }
  ]

  key_eviction_widgets = [
    for k, v in local.valkey : {
      type   = "metric"
      width  = 8
      height = 4
      properties = {
        metrics = [
          for i in local.cluster_nodes : [
            "AWS/ElastiCache",
            "Evictions",
            "CacheClusterId",
            "valkey-${k}-${var.environment}-00${i}"
          ]
        ]
        period = 3600
        region = var.region
        title  = "Valkey ${title(split("-", k)[0])}${length(split("-", k)) > 1 ? " ${upper(split("-", k)[1])}" : ""} Key Evictions"
      }
    }
  ]

  latency_widgets = [
    for k, v in local.valkey : {
      type   = "metric"
      width  = 8
      height = 4
      properties = {
        metrics = [
          for i in local.cluster_nodes : [
            "AWS/ElastiCache",
            "SuccessfulReadRequestLatency",
            "CacheClusterId",
            "valkey-${k}-${var.environment}-00${i}"
          ]
        ]
        period = 3600
        stat   = "p99"
        region = var.region
        title  = "Valkey ${title(split("-", k)[0])}${length(split("-", k)) > 1 ? " ${upper(split("-", k)[1])}" : ""} p99 Read Latency"
      }
    }
  ]
}

resource "aws_cloudwatch_dashboard" "valkey" {
  dashboard_name = "Valkey-Stats-${title(var.environment)}"
  dashboard_body = jsonencode({
    widgets = concat(
      [{
        type   = "text"
        width  = 24
        height = 2
        properties = {
          markdown = join("\n", [
            "## Valkey Cluster Stats",
            "Surfaces Valkey memory usage, key count, eviction rates, and latency"
          ])
        }
        },
        {
          type   = "text"
          width  = 24
          height = 1
          properties = {
            markdown = "### Memory Usage Percentage"
          }
      }],
      local.memory_use_widgets,
      [{
        type   = "text"
        width  = 24
        height = 1
        properties = {
          markdown = "### Key Count (Cache keys with explicit TTL set)"
        }
      }],
      local.key_count_widgets,
      [{
        type   = "text"
        width  = 24
        height = 1
        properties = {
          markdown = "### Key Evictions Count"
        }
      }],
      local.key_eviction_widgets,
      [{
        type   = "text"
        width  = 24
        height = 1
        properties = {
          markdown = "### p99 Read Latency"
        }
      }],
      local.latency_widgets,
    )
  })
}
