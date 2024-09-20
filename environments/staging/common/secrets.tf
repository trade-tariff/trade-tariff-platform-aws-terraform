module "frontend_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "frontend-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.frontend_secret_key_base
}

module "frontend_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "frontend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.frontend_sentry_dsn
}

module "backend_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "backend-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.backend_secret_key_base
}

module "slack_web_hook_url" {
  source          = "../../../modules/secret/"
  name            = "slack-web-hook-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.slack_web_hook_url
}

module "duty_calculator_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "duty-calculator-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.duty_calculator_secret_key_base
}

module "duty_calculator_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "duty-calculator-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.duty_calculator_sentry_dsn
}

module "admin_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "admin-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_secret_key_base
}

module "admin_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "admin-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_sentry_dsn
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
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_bearer_token
}

module "backend_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "backend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sentry_dsn
}

module "backend_differences_to_emails" {
  source          = "../../../modules/secret/"
  name            = "backend-differences-to-emails"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_differences_to_emails
}

module "backend_green_lanes_api_tokens" {
  source          = "../../../modules/secret/"
  name            = "backend-green-lanes-api-tokens"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_green_lanes_api_tokens
}

module "backend_sync_email" {
  source          = "../../../modules/secret/"
  name            = "backend-sync-email"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_sync_email
}

module "backend_xi_sync_host" {
  source          = "../../../modules/secret/"
  name            = "backend-xi-sync-host"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xi_sync_host
}

module "backend_xi_sync_password" {
  source          = "../../../modules/secret/"
  name            = "backend-xi-sync-password"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xi_sync_password
}

module "backend_xi_sync_username" {
  source          = "../../../modules/secret/"
  name            = "backend-xi-sync-username"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xi_sync_username
}

module "backend_uk_sync_host" {
  source          = "../../../modules/secret/"
  name            = "backend-uk-sync-host"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_uk_sync_host
}

module "backend_uk_sync_password" {
  source          = "../../../modules/secret/"
  name            = "backend-uk-sync-password"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_uk_sync_password
}

module "backend_uk_sync_username" {
  source          = "../../../modules/secret/"
  name            = "backend-uk-sync-username"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_uk_sync_username
}

module "backend_oauth_id" {
  source          = "../../../modules/secret/"
  name            = "backend-oauth-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_oauth_id
}

module "backend_oauth_secret" {
  source          = "../../../modules/secret/"
  name            = "backend-oauth-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_oauth_secret
}

module "backend_xe_api_username" {
  source          = "../../../modules/secret/"
  name            = "backend-xe-api-username"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xe_api_username
}

module "backend_xe_api_password" {
  source          = "../../../modules/secret/"
  name            = "backend-xe-api-password"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.tariff_backend_xe_api_password
}

module "signon_secret_key_base" {
  source          = "../../../modules/secret/"
  name            = "signon-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_secret_key_base
}

module "signon_devise_pepper" {
  source          = "../../../modules/secret/"
  name            = "signon-devise-pepper"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_devise_pepper
}

module "signon_devise_secret_key" {
  source          = "../../../modules/secret/"
  name            = "signon-devise-secret-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_devise_secret_key
}

module "signon_govuk_notify_api_key" {
  source          = "../../../modules/secret/"
  name            = "signon-govuk-notify-api-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_govuk_notify_api_key
}

module "signon_derivation_salt" {
  source          = "../../../modules/secret/"
  name            = "signon-derivation-salt"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_derivation_salt
}

module "signon_derivation_key" {
  source          = "../../../modules/secret/"
  name            = "signon-derivation-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.signon_derivation_key
}

module "dev_hub_backend_encryption_key" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-backend-encryption-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_backend_encryption_key
}

module "dev_hub_backend_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-backend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_backend_sentry_dsn
}

module "dev_hub_frontend_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_sentry_dsn
}

module "dev_hub_frontend_scp_open_id_client_id" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-scp-open-id-client-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_scp_open_id_client_id
}

module "dev_hub_frontend_scp_open_id_client_secret" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-scp-open-id-client-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_scp_open_id_client_secret
}

module "dev_hub_frontend_scp_open_id_secret" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-scp-open-id-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_scp_open_id_secret
}

module "fpo_search_sentry_dsn" {
  source          = "../../../modules/secret/"
  name            = "fpo-search-sentry-dsn"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.fpo_search_sentry_dsn
}

module "slack_notify_lambda_slack_webhook_url" {
  source          = "../../../modules/secret/"
  name            = "slack-notify-lambda-slack-webhook-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.slack_notify_lambda_slack_webhook_url
}

module "dev_hub_frontend_govuk_notify_api_key" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-govuk-notify-api-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_govuk_notify_api_key
}

module "dev_hub_frontend_application_support_email" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-application-support-email"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_application_support_email
}

module "dev_hub_frontend_cookie_signing_secret" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-cookie-signing-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_cookie_signing_secret
}

module "dev_hub_frontend_csrf_signing_secret" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-frontend-csrf-signing-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.dev_hub_frontend_csrf_signing_secret
}

module "commodi_tea_cookie_signing_secret" {
  source          = "../../../modules/secret/"
  name            = "commodi-tea-cookie-signing-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.commodi_tea_cookie_signing_secret
}

module "test_secret" {
  source          = "../../../modules/secret/"
  name            = "test-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 0
  create_version  = false
}
