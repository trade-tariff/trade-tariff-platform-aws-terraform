data "terraform_remote_state" "development" {
  backend = "s3"

  config = {
    bucket = "terraform-state-development-844815912454"
    key    = "common/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "staging" {
  backend = "s3"

  config = {
    bucket = "terraform-state-staging-451934005581"
    key    = "common/terraform.tfstate"
    region = var.region
  }
}

resource "aws_route53_record" "dev_name_servers" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "dev.${var.domain_name}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.development.outputs.hosted_zone_name_servers
}

import {
  to = aws_route53_record.dev_name_servers
  id = "Z0422582XJUTPNE8TYOI_dev.trade-tariff.service.gov.uk_NS"
}

resource "aws_route53_record" "staging_name_servers" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "staging.${var.domain_name}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.staging.outputs.hosted_zone_name_servers
}

import {
  to = aws_route53_record.staging_name_servers
  id = "Z0422582XJUTPNE8TYOI_staging.trade-tariff.service.gov.uk_NS"
}

resource "aws_route53_record" "sandbox_name_servers" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "sandbox.${var.domain_name}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.staging.outputs.sandbox_hosted_zone_name_servers
}

import {
  to = aws_route53_record.sandbox_name_servers
  id = "Z0422582XJUTPNE8TYOI_sandbox.trade-tariff.service.gov.uk_NS"
}

resource "aws_route53_record" "google_site_verification" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 30
  records = ["google-site-verification=cX_NM0eTiZv7isZsA-FsTMpPahArshEhyPNOKUG4Nxk"]
}

import {
  to = aws_route53_record.google_site_verification
  id = "Z0422582XJUTPNE8TYOI_trade-tariff.service.gov.uk_TXT"
}

import {
  to = module.cdn.aws_route53_record.alias_record[0]
  id = "Z0422582XJUTPNE8TYOI_trade-tariff.service.gov.uk_A"
}
