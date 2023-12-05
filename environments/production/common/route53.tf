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

resource "aws_route53_record" "staging_name_servers" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "staging.${var.domain_name}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.staging.outputs.hosted_zone_name_servers
}

resource "aws_route53_record" "sandbox_name_servers" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "sandbox.${var.domain_name}"
  type    = "NS"
  ttl     = "30"
  records = data.terraform_remote_state.staging.outputs.sandbox_hosted_zone_name_servers
}

resource "aws_route53_record" "google_site_verification" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 30
  records = ["google-site-verification=cX_NM0eTiZv7isZsA-FsTMpPahArshEhyPNOKUG4Nxk"]
}

resource "aws_route53_zone" "origin" {
  name = local.origin_domain_name
}

resource "aws_route53_record" "origin_ns" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.origin_domain_name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.origin.name_servers
}

resource "aws_route53_record" "origin_root" {
  zone_id = aws_route53_zone.origin.zone_id
  name    = local.origin_domain_name
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "origin_wildcard" {
  zone_id = aws_route53_zone.origin.zone_id
  name    = "*.${local.origin_domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
