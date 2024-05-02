module "alb" {
  source                = "../../../modules/common/application-load-balancer/"
  alb_name              = "trade-tariff-alb-${var.environment}"
  alb_security_group_id = module.alb-security-group.alb_security_group_id
  certificate_arn       = module.acm_origin.validated_certificate_arn
  public_subnet_ids     = data.terraform_remote_state.base.outputs.public_subnet_ids
  vpc_id                = data.terraform_remote_state.base.outputs.vpc_id

  custom_header = {
    name  = random_password.origin_header[0].result
    value = random_password.origin_header[1].result
  }
}
