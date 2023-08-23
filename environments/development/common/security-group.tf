module "alb-security-group" {
  source          = "../../common/security-group/"
  environment     = var.environment
  private_subnets = data.terraform_remote_state.base.outputs.private_subnets_cidr_blocks
  vpc_id          = data.terraform_remote_state.base.outputs.vpc_id
}
