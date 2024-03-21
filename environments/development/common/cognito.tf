module "cognito" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cognito?ref=aws/cognito-v1.0.1"

  pool_name              = "fpo-user-pool"
  domain                 = "auth.${var.domain_name}"
  domain_certificate_arn = module.acm.validated_certificate_arn

  client_name = "fpo-client"
}

resource "aws_route53_record" "cognito_custom_domain" {
  name    = "auth.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  alias {
    evaluate_target_health = false
    name                   = module.cognito.cloudfront_distribution_arn
    zone_id                = module.cognito.cloudfront_distribution_zone_id
  }
}
