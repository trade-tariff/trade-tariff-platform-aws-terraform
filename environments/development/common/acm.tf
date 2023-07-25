module "acm" {
  source      = "../../common/acm/"
  domain_name = var.domain_name
  environment = var.environment
}

module "acm_origin" {
  source      = "../../common/acm"
  domain_name = "origin.${var.domain_name}"
  environment = var.environment
}
