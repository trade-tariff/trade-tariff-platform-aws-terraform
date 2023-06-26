module "ecr" {
  source      = "../../common/ecr/"
  tags        = var.tags
  environment = var.environment
}
