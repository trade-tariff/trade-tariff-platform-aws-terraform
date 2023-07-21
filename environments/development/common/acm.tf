module "acm" {
  source = "../../../modules/acm/"

  domain_name = var.domain_name
  environment = var.environment
}
