module "ses" {
  source          = "../../common/ses"
  domain_name     = var.domain_name
  route53_zone_id = data.aws_route53_zone.this.zone_id
}
