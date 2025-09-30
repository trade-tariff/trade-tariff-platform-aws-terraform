locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"

  cloudfront_auth = templatefile(
    "../../../modules/cloudfront-auth.js.tpl",
    { base64 = data.aws_secretsmanager_secret_version.backups_basic_auth.secret_string }
  )

  monitored_lambdas = {
    database-backups      = "database-backups-development-backup"
    fpo-search            = "trade-tariff-lambdas-fpo-search-development-fpo_search"
    fpo-garbage-collector = "fpo-model-garbage-collection-development-collector"
    verify-auth-challenge = "trade-tariff-identity-verify-auth-challenge-response"
    create-auth-challenge = "trade-tariff-identity-create-auth-challenge"
    define-auth-challenge = "trade-tariff-identity-define-auth-challenge"
  }
}
