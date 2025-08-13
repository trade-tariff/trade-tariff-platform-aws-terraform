module "firehose_to_nr" {
  source                  = "../../../modules/firehose_delivery"
  environment             = var.environment
  newrelic_license_key    = var.newrelic_license_key
  newrelic_datacenter     = "EU"
  firehose_backups_bucket = aws_s3_bucket.this["firehose_backups"].arn
}

module "cw_metric_stream" {
  source       = "../../../modules/cloudwatch_metric_stream"
  environment  = var.environment
  firehose_arn = module.firehose_to_nr.firehose_arn
  namespaces   = ["AWS/ECS", "ECS/ContainerInsights", "AWS/RDS", "AWS/ApplicationELB"]
}
