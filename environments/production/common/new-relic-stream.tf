data "aws_secretsmanager_secret_version" "newrelic_configuration" {
  secret_id = module.newrelic_configuration.secret_arn
}

locals {
  newrelic_secret_value = try(
    data.aws_secretsmanager_secret_version.newrelic_configuration.secret_string,
    error("Failed to retrieve New Relic secret from AWS Secrets Manager. Please ensure the secret exists and is accessible.")
  )
  newrelic_secret_map   = jsondecode(local.newrelic_secret_value)

  newrelic_license_key = local.newrelic_secret_map["license_key"]
}

module "firehose_to_nr" {
  source                  = "../../../modules/firehose_delivery"
  environment             = var.environment
  newrelic_license_key    = local.newrelic_license_key
  newrelic_datacenter     = "EU"
  firehose_backups_bucket = aws_s3_bucket.this["firehose_backups"].arn
}

module "cw_metric_stream" {
  source       = "../../../modules/cloudwatch_metric_stream"
  environment  = var.environment
  firehose_arn = module.firehose_to_nr.firehose_arn

  include_metric_filters = {
    "ECS/ContainerInsights" = [],
    "AWS/ECS"               = [],
    "AWS/RDS"               = []
  }
}
