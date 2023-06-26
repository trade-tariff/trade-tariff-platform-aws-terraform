module "redis" {
  source = "../../common/elasticache/"

  environment = var.environment
  region      = var.region

  cloudwatch_log_group = aws_cloudwatch_log_group.this.name

  group_name      = "tariff-redis-${var.environment}"
  redis_version   = "5.0.6"
  instance_type   = "cache.t3.micro"
  parameter_group = "default.redis5.0.cluster.on"
  replicas        = 1

  maintenance_window = "sun:00:00-sun:03:00"
  snapshot_window    = "00:00-02:00"
}
