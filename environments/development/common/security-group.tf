module "alb-security-group" {
  source      = "../../common/security-group/"
  environment = var.environment
}
