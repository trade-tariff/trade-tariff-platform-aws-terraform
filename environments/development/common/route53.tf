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

resource "aws_route53_record" "subdomains" {
  for_each = toset(["admin", "signon"])
  zone_id  = data.aws_route53_zone.this.zone_id
  name     = "${each.value}.${var.domain_name}"
  type     = "A"

  alias {
    name                   = module.cdn.aws_cloudfront_distribution_domain_name
    zone_id                = module.cdn.aws_cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}
