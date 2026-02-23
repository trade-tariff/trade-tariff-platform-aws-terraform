locals {
  redis = {
    "frontend"   = "cache.t3.micro",
    "backend-uk" = "cache.t3.micro",
    "backend-xi" = "cache.t3.micro",
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "redis-subnet-group"
  subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids
}

module "redis" {
  source   = "../../../modules/elasticache/"
  for_each = local.redis

  engine         = "valkey"
  engine_version = "8.1"

  replication_group_id        = "redis-${each.key}-${var.environment}"
  description                 = "redis-${each.key}-${var.environment}"
  parameter_group_name        = "default.valkey8"
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
  log_retention_days          = 7
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

resource "aws_elasticache_parameter_group" "sidekiq" {
  name   = "valkey8-noeviction"
  family = "valkey8"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

locals {
  redis_sidekiq = {
    "sidekiq-uk" = "cache.t3.micro",
    "sidekiq-xi" = "cache.t3.micro",
  }
}

module "redis_sidekiq" {
  source   = "../../../modules/elasticache/"
  for_each = local.redis_sidekiq

  engine         = "valkey"
  engine_version = "8.1"

  replication_group_id        = "redis-${each.key}-${var.environment}"
  description                 = "redis-${each.key}-${var.environment}"
  parameter_group_name        = aws_elasticache_parameter_group.sidekiq.name
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
  log_retention_days          = 7
}

resource "aws_secretsmanager_secret" "redis_sidekiq_connection_string" {
  for_each   = local.redis_sidekiq
  name       = "redis-${each.key}-connection-string"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "redis_sidekiq_connection_string_value" {
  for_each      = local.redis_sidekiq
  secret_id     = aws_secretsmanager_secret.redis_sidekiq_connection_string[each.key].id
  secret_string = "redis://${module.redis_sidekiq[each.key].primary_endpoint}:6379"
}
