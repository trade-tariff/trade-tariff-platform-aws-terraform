module "frontend_secret_key_base" {
  source          = "../../common/secret/"
  name            = "frontend-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.frontend_secret_key_base
}

module "frontend_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "frontend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.frontend_sentry_dsn
}

module "backend_secret_key_base" {
  source          = "../../common/secret/"
  name            = "backend-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.backend_secret_key_base
}

module "duty_calculator_secret_key_base" {
  source          = "../../common/secret/"
  name            = "duty-calculator-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.duty_calculator_secret_key_base
}

module "duty_calculator_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "duty-calculator-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.duty_calculator_sentry_dsn
}

module "admin_secret_key_base" {
  source          = "../../common/secret/"
  name            = "admin-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_secret_key_base
}

module "admin_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "admin-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_sentry_dsn
}

module "admin_oauth_id" {
  source          = "../../common/secret/"
  name            = "admin-oauth-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_oauth_id
}

module "admin_oauth_secret" {
  source          = "../../common/secret/"
  name            = "admin-oauth-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_oauth_secret
}

module "admin_bearer_token" {
  source          = "../../common/secret/"
  name            = "admin-bearer-token"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_bearer_token
}

module "backend_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "backend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sentry_dsn
}

module "backend_differences_to_emails" {
  source          = "../../common/secret/"
  name            = "backend-differences-to-emails"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_differences_to_emails
}

module "backend_sync_email" {
  source          = "../../common/secret/"
  name            = "backend-sync-email"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sync_email
}

module "backend_xi_sync_host" {
  source          = "../../common/secret/"
  name            = "backend-xi-sync-host"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xi_sync_host
}

module "backend_xi_sync_password" {
  source          = "../../common/secret/"
  name            = "backend-xi-sync-password"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xi_sync_password
}

module "backend_xi_sync_username" {
  source          = "../../common/secret/"
  name            = "backend-xi-sync-username"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xi_sync_username
}

module "backend_uk_sync_host" {
  source          = "../../common/secret/"
  name            = "backend-uk-sync-host"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_uk_sync_host
}

module "backend_uk_sync_password" {
  source          = "../../common/secret/"
  name            = "backend-uk-sync-password"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_uk_sync_password
}

module "backend_uk_sync_username" {
  source          = "../../common/secret/"
  name            = "backend-uk-sync-username"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_uk_sync_username
}


module "backend_oauth_id" {
  source          = "../../common/secret/"
  name            = "backend-oauth-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_oauth_id
}

module "backend_oauth_secret" {
  source          = "../../common/secret/"
  name            = "backend-oauth-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_oauth_secret
}

module "search_query_parser_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "search-query-parser-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.search_query_parser_sentry_dsn
}
