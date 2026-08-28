locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"

  cloudfront_auth = templatefile(
    "../../../modules/cloudfront-auth.js.tpl",
    { base64 = data.aws_secretsmanager_secret_version.backups_basic_auth.secret_string }
  )

  monitored_lambdas = {
    database-backups      = "database-backups-production-backup"
    fpo-search            = "trade-tariff-lambdas-fpo-search-production-fpo_search"
    fpo-garbage-collector = "fpo-model-garbage-collection-production-collector"
    verify-auth-challenge = "trade-tariff-identity-verify-auth-challenge-response"
    create-auth-challenge = "trade-tariff-identity-create-auth-challenge"
    define-auth-challenge = "trade-tariff-identity-define-auth-challenge"
  }

  newrelic_secret_value = try(
    data.aws_secretsmanager_secret_version.newrelic_configuration.secret_string,
    error("Failed to retrieve New Relic secret from AWS Secrets Manager. Please ensure the secret exists and is accessible.")
  )
  newrelic_secret_map = jsondecode(local.newrelic_secret_value)

  newrelic_license_key            = local.newrelic_secret_map["license_key"]
  newrelic_account_id             = local.newrelic_secret_map["account_id"]
  newrelic_user_key               = local.newrelic_secret_map["user_key"]
  newrelic_aws_trusted_account_id = local.newrelic_secret_map["aws_trusted_account_id"]
}
