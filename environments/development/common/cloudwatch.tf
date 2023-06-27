module "cloudwatch" {
  source            = "../../common/cloudwatch/"
  name              = "platform-logs-${var.environment}"
  retention_in_days = 31
  region            = var.region
}
