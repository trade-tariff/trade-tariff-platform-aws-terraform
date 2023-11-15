module "acm" {
  source         = "../../common/acm/"
  domain_name    = var.domain_name
  environment    = var.environment
  hosted_zone_id = data.aws_route53_zone.this.zone_id

  providers = {
    aws = aws.us_east_1
  }
}

module "acm_alb" {
  source         = "../../common/acm/"
  domain_name    = var.domain_name
  environment    = var.environment
  hosted_zone_id = data.aws_route53_zone.this.zone_id
}
