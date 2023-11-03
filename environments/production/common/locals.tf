locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"
  tariff_domain      = "trade-tariff.service.gov.uk"
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

data "aws_route53_zone" "trade_tariff" {
  name         = local.tariff_domain
  private_zone = false
}
