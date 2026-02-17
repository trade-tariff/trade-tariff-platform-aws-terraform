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

module "dev_hub_job_configuration" {
  source          = "../../../modules/secret/"
  name            = "dev-hub-job-configuration"
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

module "backend_job_configuration" {
  source          = "../../../modules/secret/"
  name            = "backend-job-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

# TODO: Remove me once migrated to consistent naming
module "db_replicate_configuration" {
  source          = "../../../modules/secret/"
  name            = "db-replicate-configuration"
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

module "fpo_search_configuration" {
  source          = "../../../modules/secret/"
  name            = "fpo-search-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "identity_configuration" {
  source          = "../../../modules/secret/"
  name            = "identity-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "slack_notify_lambda_slack_webhook_url" {
  source          = "../../../modules/secret/"
  name            = "slack-notify-lambda-slack-webhook-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "backups_basic_auth" {
  source          = "../../../modules/secret/"
  name            = "backups-basic-auth"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "identity_create_auth_challenge_configuration" {
  source          = "../../../modules/secret/"
  name            = "identity-create-auth-challenge-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "newrelic_configuration" {
  source          = "../../../modules/secret/"
  name            = "newrelic-configuration"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}

module "apigw_internal_test_key" {
  source          = "../../../modules/secret/"
  name            = "apigw-${var.environment}-internal-test-api-key"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
}
