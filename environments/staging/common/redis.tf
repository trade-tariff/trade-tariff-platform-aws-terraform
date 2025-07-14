locals {
  redis = toset([
    "frontend",
    "backend-uk",
    "backend-xi",
  ])
}

moved {
  from = aws_elasticache_subnet_group.this
  to   = module.redis.aws_elasticache_subnet_group.this
}

moved {
  from = aws_cloudwatch_log_group.redis_slow_lg
  to   = module.redis.aws_cloudwatch_log_group.slow_lg
}

moved {
  from = aws_cloudwatch_log_group.redis_engine_lg
  to   = module.redis.aws_cloudwatch_log_group.engine_lg
}

module "redis" {
  source   = "../../../modules/elasticache/"
  for_each = local.redis

  engine         = "valkey"
  engine_version = "7.2"

  replication_group_id        = "redis-${each.key}-${var.environment}"
  description                 = "redis-${each.key}-${var.environment}"
  parameter_group_name        = "default.valkey7"
  num_node_groups             = 1
  replicas_per_node_group     = 2
  node_type                   = "cache.t3.micro"
  security_group_ids          = [module.alb-security-group.redis_security_group_id]
  subnet_ids                  = data.terraform_remote_state.base.outputs.private_subnet_ids
  multi_az_enabled            = true
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  auto_minor_version_upgrade  = true
  maintenance_window          = "sun:04:00-sun:05:00"
  snapshot_window             = "02:00-04:00"
  snapshot_retention_limit    = 7
  apply_immediately           = true
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
