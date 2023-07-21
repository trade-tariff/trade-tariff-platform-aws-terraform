module "frontend_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "frontend-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.frontend_secret_key_base
}

module "backend_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "backend-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.backend_secret_key_base
}

module "duty_calculator_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "duty-calculator-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.duty_calculator_secret_key_base
}

module "newrelic_license_key" {
  source          = "../../../modules/secret/"
  name            = "newrelic-license-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.newrelic_license_key
}

module "admin_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "admin-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_secret_key_base
}

module "admin_oauth_id" {
  source          = "../../../modules/secret/"
  name            = "admin-oauth-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_oauth_id
}

module "admin_oauth_secret" {
  source          = "../../../modules/secret/"
  name            = "admin-oauth-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_oauth_secret
}

module "admin_bearer_token" {
  source          = "../../../modules/secret/"
  name            = "admin-bearer-token"
  kms_key_arn     = aws_kms_key.opensearch_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_bearer_token
}

module "backend_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "backend_sentry_dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sentry_dsn
}

module "backend_sync_email" {
  source          = "../../../modules/secret/"
  name            = "backend_sync_email"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sync_email
}

module "backend_sync_host" {
  source          = "../../../modules/secret/"
  name            = "backend_sync_host"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sync_host
}

module "backend_sync_password" {
  source          = "../../../modules/secret/"
  name            = "backend_sync_password"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sync_password
}

module "backend_sync_username" {
  source          = "../../../modules/secret/"
  name            = "backend_sync_username"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sync_username
}

module "backend_oauth_id" {
  source          = "../../../modules/secret/"
  name            = "backend_oauth_id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_oauth_id
}

module "backend_oauth_secret" {
  source          = "../../../modules/secret/"
  name            = "backend_oauth_secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_oauth_secret
}
