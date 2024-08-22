module "acm" {
  source                    = "../../../modules/common/acm/"
  domain_name               = var.domain_name
  environment               = var.environment
  hosted_zone_id            = data.aws_route53_zone.this.zone_id
  subject_alternative_names = var.subject_alternative_names

  providers = {
    aws = aws.us_east_1
  }
}

module "acm_london" {
  source         = "../../../modules/common/acm/"
  domain_name    = var.domain_name
  environment    = var.environment
  hosted_zone_id = data.aws_route53_zone.this.zone_id
}

module "acm_origin" {
  source         = "../../../modules/common/acm"
  domain_name    = "origin.${var.domain_name}"
  environment    = var.environment
  hosted_zone_id = aws_route53_zone.origin.zone_id
}
