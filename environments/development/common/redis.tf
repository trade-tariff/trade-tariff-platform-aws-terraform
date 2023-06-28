module "redis" {
  source = "../../common/elasticache/"

  environment = var.environment
  region      = var.region

  cloudwatch_log_group = module.cloudwatch.log_group_name

  group_name      = "tariff-redis-${var.environment}"
  redis_version   = "5.0.6"
  instance_type   = "cache.t3.micro"
  parameter_group = "default.redis5.0.cluster.on"

  shards   = 2
  replicas = 1

  maintenance_window = "sun:00:00-sun:03:00"
  snapshot_window    = "04:00-06:00"
}
