module "acm" {
  source         = "../../../modules/acm/"
  domain_name    = var.domain_name
  environment    = var.environment
  hosted_zone_id = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "admin.${var.domain_name}",
    "api.${var.domain_name}",
    "auth.id.${var.domain_name}",
    "docs.${var.domain_name}",
    "dumps.${var.domain_name}",
    "eval.${var.domain_name}",
    "examples.${var.domain_name}",
    "flags-edge.${var.domain_name}",
    "flags.${var.domain_name}",
    "hub.${var.domain_name}",
    "id.${var.domain_name}",
    "mcp.${var.domain_name}",
    "reporting.${var.domain_name}",
    "search.${var.domain_name}"
  ]

  providers = {
    aws = aws.us_east_1
  }
}

module "acm_london" {
  source         = "../../../modules/acm/"
  domain_name    = var.domain_name
  environment    = var.environment
  hosted_zone_id = data.aws_route53_zone.this.zone_id
}

module "acm_origin" {
  source         = "../../../modules/acm"
  domain_name    = "origin.${var.domain_name}"
  environment    = var.environment
  hosted_zone_id = aws_route53_zone.origin.zone_id
}
