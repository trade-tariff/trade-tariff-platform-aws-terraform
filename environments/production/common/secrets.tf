module "admin_configuration" {
  source          = "../../../modules/secret/"
  name            = "admin-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "commodi_tea_configuration" {
  source          = "../../../modules/secret/"
  name            = "commodi-tea-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "dev_hub_configuration" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "duty_calculator_configuration" {
  source          = "../../../modules/secret/"
  name            = "duty-calculator-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "frontend_configuration" {
  source          = "../../../modules/secret/"
  name            = "frontend-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "backend_uk_worker_configuration" {
  source          = "../../../modules/secret/"
  name            = "backend-uk-worker-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "backend_xi_worker_configuration" {
  source          = "../../../modules/secret/"
  name            = "backend-xi-worker-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "backend_uk_api_configuration" {
  source          = "../../../modules/secret/"
  name            = "backend-uk-api-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "backend_xi_api_configuration" {
  source          = "../../../modules/secret/"
  name            = "backend-xi-api-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "download_cds_files_configuration" {
  source          = "../../../modules/secret/"
  name            = "download-cds-files-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "etf_configuration" {
  source          = "../../../modules/secret/"
  name            = "electronic-tariff-file-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "db_replicate_configuration" {
  source          = "../../../modules/secret/"
  name            = "db-replicate-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "fpo_search_configuration" {
  source          = "../../../modules/secret/"
  name            = "fpo-search-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "slack_notify_lambda_slack_webhook_url" {
  source          = "../../../modules/secret/"
  name            = "slack-notify-lambda-slack-webhook-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}
