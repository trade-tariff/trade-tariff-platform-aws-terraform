locals {
  redis = toset([
    "frontend",
    "backend",
    "admin"
  ])
}

module "redis" {
  source   = "../../common/elasticache/"
  for_each = local.redis

  group_name           = "redis-${each.key}-${var.environment}"
  redis_version        = "5.0.6"
  instance_type        = "cache.t3.micro"
  parameter_group      = "default.redis5.0"
  cloudwatch_log_group = module.cloudwatch.log_group_name

  security_group_ids = [module.alb-security-group.redis_security_group_id]

  maintenance_window = "sun:04:00-sun:05:00"
  snapshot_window    = "02:00-04:00"
}

resource "aws_secretsmanager_secret" "redis_connection_string" {
  for_each   = local.redis
  name       = "redis-${each.key}-connection-string"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "redis_connection_string_value" {
  for_each      = local.redis
  secret_id     = aws_secretsmanager_secret.redis_connection_string[each.key].id
  secret_string = "redis://${module.redis[each.key].endpoint}:6379"
}
