locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"

  applications = [
    "admin",
    "backend",
    "duty-calculator",
    "frontend",
    "search-query-parser",
    "signon"
  ]
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}
