module "alb-security-group" {
  source = "../../common/security-group/"

  cidr_block  = var.cidr_block
  environment = var.environment
}
