locals {
  account_id    = data.aws_caller_identity.current.account_id
  tariff_domain = "trade-tariff.service.gov.uk"
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}
