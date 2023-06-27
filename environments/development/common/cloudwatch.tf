module "cloudwatch" {
  source            = "../../common/cloudwatch/"
  name              = "platform-logs-${var.environment}"
  retention_in_days = 30
  region            = var.region
}
