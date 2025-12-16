module "gateway" {
  source = "../../../modules/api-gateway"

  environment               = var.environment
  domain_name               = var.domain_name
  validated_certificate_arn = module.acm_london.validated_certificate_arn
  zone_id                   = data.aws_route53_zone.this.zone_id
  security_group_ids        = [module.alb-security-group.alb_security_group_id]
  private_subnet_ids        = data.terraform_remote_state.base.outputs.private_subnet_ids
  lb_arn                    = module.alb.lb_arn
  cache_cluster_enabled     = true
  cache_cluster_size        = "0.5"
  log_level                 = "INFO"

  alb_secret_header = [
    random_password.origin_header[0].result,
    random_password.origin_header[1].result
  ]
}
