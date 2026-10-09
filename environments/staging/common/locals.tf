locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"

  dev_hub_max_keys_per_organisation = 3
  waf_apigw_rpm_limit               = local.dev_hub_max_keys_per_organisation * var.apigw_default_rate_limit * 60

  cloudfront_auth = templatefile(
    "../../../modules/cloudfront-auth.js.tpl",
    { base64 = data.aws_secretsmanager_secret_version.backups_basic_auth.secret_string }
  )

  monitored_lambdas = {
    database-backups      = "database-backups-staging-backup"
    fpo-garbage-collector = "fpo-model-garbage-collection-staging-collector"
    verify-auth-challenge = "trade-tariff-identity-verify-auth-challenge-response"
    create-auth-challenge = "trade-tariff-identity-create-auth-challenge"
    define-auth-challenge = "trade-tariff-identity-define-auth-challenge"
  }
}
