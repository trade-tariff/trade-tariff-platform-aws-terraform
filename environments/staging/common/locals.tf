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
    "signon",
    "tea"
  ]

  cloudfront_auth = templatefile("../../../modules/cloudfront-auth.js.tpl", { base64 = var.backups_basic_auth })
}

data "aws_caller_identity" "current" {}
