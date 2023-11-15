locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"

  applications = [
    "admin",
    "backend",
    "database-backups",
    "duty-calculator",
    "fpo-search",
    "frontend",
    "search-query-parser",
    "signon",
  ]
}

data "aws_caller_identity" "current" {}
