locals {
  redis = toset([
    "frontend",
    "backend",
    "admin"
  ])
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "redis-subnet-group"
  subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids
}

# tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "redis_slow_lg" {
  for_each          = local.redis
  name              = "redis-${each.key}-${var.environment}-slow-lg"
  retention_in_days = 30
}

# tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "redis_engine_lg" {
  for_each          = local.redis
  name              = "redis-${each.key}-${var.environment}-engine-lg"
  retention_in_days = 30
}

### Single node redis cluster - v1 deployment (resulted in connectivity issues due to endpoints being blank)
# module "redis" {
#   source   = "../../common/elasticache/"
#   for_each = local.redis

#   group_name           = "redis-${each.key}-${var.environment}"
#   redis_version        = "5.0.6"
#   instance_type        = "cache.t3.micro"
#   parameter_group      = "default.redis5.0"
#   cloudwatch_log_group = module.cloudwatch.log_group_name

#   security_group_ids = [module.alb-security-group.redis_security_group_id]
#   subnet_group_name  = aws_elasticache_subnet_group.this.name

#   maintenance_window = "sun:04:00-sun:05:00"
#   snapshot_window    = "02:00-04:00"
# }

# resource "aws_elasticache_subnet_group" "this" {
#   name       = "redis-subnet-group"
#   subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids
# }

# resource "aws_secretsmanager_secret" "redis_connection_string" {
#   for_each   = local.redis
#   name       = "redis-${each.key}-connection-string"
#   kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
# }

# resource "aws_secretsmanager_secret_version" "redis_connection_string_value" {
#   for_each      = local.redis
#   secret_id     = aws_secretsmanager_secret.redis_connection_string[each.key].id
#   secret_string = "redis://${module.redis[each.key].endpoint}:6379"
# }

### Multi node redis with cluster mode disabled (one primary and two replica nodes spread across all 3 availability zones)
module "redis" {
  source   = "../../common/elasticache-redis/"
  for_each = local.redis

  replication_group_id        = "redis-${each.key}-${var.environment}"
  description                 = "redis-${each.key}-${var.environment}"
  parameter_group_name        = "default.redis7"
  num_node_groups             = 1
  replicas_per_node_group     = 2
  node_type                   = "cache.t3.micro"
  security_group_ids          = [module.alb-security-group.redis_security_group_id]
  subnet_group_name           = aws_elasticache_subnet_group.this.name
  multi_az_enabled            = true
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

  # # tfsec:ignore:aws-elasticache-enable-at-rest-encryption
  # at_rest_encryption_enabled = false
  # # tfsec:ignore:aws-elasticache-enable-in-transit-encryption
  # transit_encryption_enabled = false

  auto_minor_version_upgrade = true
  maintenance_window         = "sun:04:00-sun:05:00"
  snapshot_window            = "02:00-04:00"
  snapshot_retention_limit   = 7

  log_delivery_configuration = [
    {
      destination      = aws_cloudwatch_log_group.redis_slow_lg[each.key].name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "slow-log"
    },
    {
      destination      = aws_cloudwatch_log_group.redis_engine_lg[each.key].name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "engine-log"
    }
  ]

  apply_immediately = true
  tags              = var.tags
}

resource "aws_secretsmanager_secret" "redis_connection_string" {
  for_each   = local.redis
  name       = "redis-${each.key}-connection-string"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "redis_connection_string_value" {
  for_each      = local.redis
  secret_id     = aws_secretsmanager_secret.redis_connection_string[each.key].id
  secret_string = "redis://${module.redis[each.key].primary_endpoint}:6379"
}

resource "aws_secretsmanager_secret" "redis_reader_connection_string" {
  for_each   = local.redis
  name       = "redis-${each.key}-reader-connection-string"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "redis_reader_connection_string_value" {
  for_each      = local.redis
  secret_id     = aws_secretsmanager_secret.redis_reader_connection_string[each.key].id
  secret_string = "redis://${module.redis[each.key].reader_endpoint}:6379"
}
