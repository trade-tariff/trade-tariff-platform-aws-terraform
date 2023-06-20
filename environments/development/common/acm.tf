module "acm" {
  source = "../../common/acm/"

  domain_name = var.domain_name
  environment = var.environment
}
