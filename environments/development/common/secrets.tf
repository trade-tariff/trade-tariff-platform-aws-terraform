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

module "slack_web_hook_url" {
  source          = "../../common/secret/"
  name            = "slack-web-hook-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.slack_web_hook_url
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

module "backend_green_lanes_api_tokens" {
  source          = "../../common/secret/"
  name            = "backend-green-lanes-api-tokens"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_green_lanes_api_tokens
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

module "backend_xe_api_username" {
  source          = "../../common/secret/"
  name            = "backend-xe-api-username"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xe_api_username
}

module "backend_xe_api_password" {
  source          = "../../common/secret/"
  name            = "backend-xe-api-password"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xe_api_password
}

module "signon_secret_key_base" {
  source          = "../../common/secret/"
  name            = "signon-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_secret_key_base
}

module "signon_devise_pepper" {
  source          = "../../common/secret/"
  name            = "signon-devise-pepper"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_devise_pepper
}

module "signon_devise_secret_key" {
  source          = "../../common/secret/"
  name            = "signon-devise-secret-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_devise_secret_key
}

module "signon_govuk_notify_api_key" {
  source          = "../../common/secret/"
  name            = "signon-govuk-notify-api-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_govuk_notify_api_key
}

module "signon_derivation_salt" {
  source          = "../../common/secret/"
  name            = "signon-derivation-salt"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_derivation_salt
}

module "signon_derivation_key" {
  source          = "../../common/secret/"
  name            = "signon-derivation-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_derivation_key
}

module "search_query_parser_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "search-query-parser-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.search_query_parser_sentry_dsn
}

module "dev_hub_backend_encryption_key" {
  source          = "../../common/secret/"
  name            = "dev-hub-backend-encryption-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_backend_encryption_key
}

module "dev_hub_backend_usage_plan_id" {
  source          = "../../common/secret/"
  name            = "dev-hub-backend-usage-plan-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_backend_usage_plan_id
}

module "dev_hub_backend_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "dev-hub-backend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_backend_sentry_dsn
}

module "dev_hub_frontend_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "dev-hub-frontend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_sentry_dsn
}

module "fpo_search_sentry_dsn" {
  source          = "../../common/secret/"
  name            = "fpo-search-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.fpo_search_sentry_dsn
}

module "fpo_search_training_pem" {
  source          = "../../common/secret/"
  name            = "fpo-search-training-pem"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.fpo_search_training_pem
}

module "slack_notify_lambda_slack_webhook_url" {
  source          = "../../common/secret/"
  name            = "slack-notify-lambda-slack-webhook-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.slack_notify_lambda_slack_webhook_url
}
