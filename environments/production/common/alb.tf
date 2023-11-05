module "alb" {
  source                = "../../common/application-load-balancer/"
  alb_name              = "trade-tariff-alb-${var.environment}"
  alb_security_group_id = module.alb-security-group.alb_security_group_id
  public_subnet_ids     = data.terraform_remote_state.base.outputs.public_subnet_ids
  certificate_arn       = module.acm.validated_certificate_arn
  vpc_id                = data.terraform_remote_state.base.outputs.vpc_id
}
