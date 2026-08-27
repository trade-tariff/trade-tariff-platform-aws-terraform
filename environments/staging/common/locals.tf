locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"

  # Client keys authorized for the legacy categorisation X-Api-Key API.
  # Kept in sync with the backend's own auth check, which reads the same secret.
  xi_api_keys = jsondecode(data.aws_secretsmanager_secret_version.xi_api_configuration.secret_string)["api_keys"]

  cloudfront_auth = templatefile(
    "../../../modules/cloudfront-auth.js.tpl",
    { base64 = data.aws_secretsmanager_secret_version.backups_basic_auth.secret_string }
  )

  monitored_lambdas = {
    database-backups      = "database-backups-staging-backup"
    fpo-search            = "trade-tariff-lambdas-fpo-search-staging-fpo_search"
    fpo-garbage-collector = "fpo-model-garbage-collection-staging-collector"
    verify-auth-challenge = "trade-tariff-identity-verify-auth-challenge-response"
    create-auth-challenge = "trade-tariff-identity-create-auth-challenge"
    define-auth-challenge = "trade-tariff-identity-define-auth-challenge"
  }
}
