module "acm" {
  source = "../../acm/"

  domain_name        = var.domain_name
  environment        = var.environment
  alternative_names  = var.alternative_name
  validation_method  = var.validation_method
  private_zone       = var.private_zone
}
