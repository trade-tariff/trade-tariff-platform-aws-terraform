module "alb" {
  source                = "../../common/application-load-balancer/"
  alb_name              = var.alb_name
  alb_security_group_id = module.alb-security-group.alb_security_group_id
  public_subnet_id      = var.public_subnet_id
  certificate_arn       = module.acm.certificate_arn
  environment           = var.environment
}
