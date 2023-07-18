module "frontend_secret_key_base" {
  source          = "../../common/secret/"
  name            = "frontend-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.frontend_secret_key_base
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

module "newrelic_license_key" {
  source          = "../../common/secret/"
  name            = "newrelic-license-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.newrelic_license_key
}

module "admin_secret_key_base" {
  source          = "../../common/secret/"
  name            = "admin-secret-key-base"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_secret_key_base
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
  kms_key_arn     = aws_kms_key.opensearch_kms_key.arn
  recovery_window = 7
  secret_string   = var.admin_bearer_token
}
