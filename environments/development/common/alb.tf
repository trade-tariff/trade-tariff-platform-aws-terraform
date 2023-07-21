module "alb" {
  source                = "../../../modules/application-load-balancer/"
  alb_name              = var.alb_name
  alb_security_group_id = aws_security_group.alb_security_group.id
  public_subnet_id      = data.terraform_remote_state.base.outputs.public_subnet_id
  certificate_arn       = module.acm.certificate_arn
  environment           = var.environment
  vpc_id                = data.terraform_remote_state.base.outputs.vpc_id
}
