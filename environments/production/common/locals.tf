locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = module.alb.dns_name

  tariff_domain   = "trade-tariff.service.gov.uk"
  cloudfront_auth = templatefile("../../common/cloudfront-auth.js.tpl", { base64 = var.backups_basic_auth })
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name         = local.tariff_domain
  private_zone = false
}
