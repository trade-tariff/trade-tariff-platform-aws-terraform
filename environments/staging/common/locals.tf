locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"

  applications = [
    "admin",
    "backend",
    "database-backups",
    "database-replication",
    "duty-calculator",
    "fpo-developer-hub-backend",
    "fpo-developer-hub-frontend",
    "fpo-search",
    "frontend",
    "tea"
  ]

  cloudfront_auth = templatefile(
    "../../../modules/cloudfront-auth.js.tpl",
    { base64 = data.aws_secretsmanager_secret_version.backups_basic_auth.secret_string }
  )
}
