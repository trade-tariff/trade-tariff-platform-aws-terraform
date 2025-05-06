module "admin_configuration" {
  source                = "../../../modules/secret/"
  name                  = "admin-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "commodi_tea_configuration" {
  source                = "../../../modules/secret/"
  name                  = "commodi-tea-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "dev_hub_configuration" {
  source                = "../../../modules/secret/"
  name                  = "dev-hub-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "duty_calculator_configuration" {
  source                = "../../../modules/secret/"
  name                  = "duty-calculator-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "frontend_configuration" {
  source                = "../../../modules/secret/"
  name                  = "frontend-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "backend_uk_worker_configuration" {
  source                = "../../../modules/secret/"
  name                  = "backend-uk-worker-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "backend_xi_worker_configuration" {
  source                = "../../../modules/secret/"
  name                  = "backend-xi-worker-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "backend_uk_api_configuration" {
  source                = "../../../modules/secret/"
  name                  = "backend-uk-api-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "backend_xi_api_configuration" {
  source                = "../../../modules/secret/"
  name                  = "backend-xi-api-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

module "db_replicate_configuration" {
  source                = "../../../modules/secret/"
  name                  = "db-replicate-configuration"
  kms_key_arn           = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window       = 7
  create_secret_version = false
}

######### OLD WORLD SECRETS START HERE ##########

module "fpo_search_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "fpo-search-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.fpo_search_sentry_dsn
}

module "fpo_search_training_pem" {
  source          = "../../../modules/secret/"
  name            = "fpo-search-training-pem"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.fpo_search_training_pem
}

module "slack_notify_lambda_slack_webhook_url" {
  source          = "../../../modules/secret/"
  name            = "slack-notify-lambda-slack-webhook-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.slack_notify_lambda_slack_webhook_url
}

module "commodi_tea_cookie_signing_secret" {
  source          = "../../../modules/secret/"
  name            = "commodi-tea-cookie-signing-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.commodi_tea_cookie_signing_secret
}

module "commodi_tea_fpo_search_api_key" {
  source          = "../../../modules/secret/"
  name            = "commodi-tea-fpo-search-api-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.commodi_tea_fpo_search_api_key
}
