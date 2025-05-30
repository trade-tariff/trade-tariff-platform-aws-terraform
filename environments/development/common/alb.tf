module "alb" {
  source                = "../../../modules/application-load-balancer/"
  alb_name              = "trade-tariff-alb-${var.environment}"
  alb_security_group_id = module.alb-security-group.alb_security_group_id
  certificate_arn       = module.acm_origin.validated_certificate_arn
  public_subnet_ids     = data.terraform_remote_state.base.outputs.public_subnet_ids
  vpc_id                = data.terraform_remote_state.base.outputs.vpc_id

  custom_header = {
    name  = random_password.origin_header[0].result
    value = random_password.origin_header[1].result
  }

  services = {
    admin = {
      hosts            = ["admin.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 1
    }

    tea = {
      hosts            = ["tea.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 5
    }

    identity = {
      hosts            = ["id.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 10
    }

    duty_calculator = {
      paths            = ["/duty-calculator/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 17
    }

    backend_uk = {
      paths = [
        "/users/*",
        "/api/*",
        "/uk/api/*",
        "/uk/users/*"
      ]
      healthcheck_path = "/healthcheckz"
      priority         = 20
    }

    backend_xi = {
      paths            = ["/xi/api/*", "/xi/users/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 21
    }

    hub = {
      hosts            = ["hub.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 22
    }

    frontend = {
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 99 # Most generic rule for frontend should match last
    }
  }
}

module "alb_preview" {
  source                = "../../../modules/application-load-balancer/"
  alb_name              = "alb-preview-${var.environment}"
  alb_security_group_id = module.alb-security-group.alb_security_group_id
  certificate_arn       = module.acm_origin.validated_certificate_arn
  public_subnet_ids     = data.terraform_remote_state.base.outputs.public_subnet_ids
  vpc_id                = data.terraform_remote_state.base.outputs.vpc_id

  custom_header = {
    name  = random_password.origin_header[0].result
    value = random_password.origin_header[1].result
  }

  services = {
    hub_backend_preview = {
      hosts            = ["hub.*"]
      paths            = ["/api/healthcheck"]
      healthcheck_path = "/api/healthcheckz"
      priority         = 40
    }
  }
}
