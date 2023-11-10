module "acm" {
  source         = "../../common/acm/"
  domain_name    = var.domain_name
  environment    = var.environment
  hosted_zone_id = data.aws_route53_zone.this.zone_id

  providers = {
    aws = aws.us_east_1
  }
}

module "acm_origin" {
  source         = "../../common/acm"
  domain_name    = "origin.${var.domain_name}"
  environment    = var.environment
  hosted_zone_id = aws_route53_zone.origin.zone_id
}

module "acm_reporting" {
  source         = "../../common/acm"
  domain_name    = "reporting.${var.domain_name}"
  environment    = var.environment
  hosted_zone_id = aws_route53_zone.origin.zone_id
}

module "acm_api" {
  source         = "../../common/acm"
  domain_name    = "api.${var.domain_name}"
  environment    = var.environment
  hosted_zone_id = aws_route53_zone.origin.zone_id
}

module "acm_dumps" {
  source         = "../../common/acm"
  domain_name    = "dumps.${var.domain_name}"
  environment    = var.environment
  hosted_zone_id = aws_route53_zone.origin.zone_id
}
