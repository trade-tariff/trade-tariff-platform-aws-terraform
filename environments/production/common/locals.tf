locals {
  account_id         = data.aws_caller_identity.current.account_id
  origin_domain_name = "origin.${var.domain_name}"
  cloudfront_auth    = templatefile("../../../modules/cloudfront-auth.js.tpl", { base64 = var.backups_basic_auth })
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}
