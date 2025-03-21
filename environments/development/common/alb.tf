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

    signon = {
      hosts            = ["signon.*"]
      healthcheck_path = "/healthcheck/live"
      priority         = 2
    }

    hub_backend = {
      hosts            = ["hub.*"]
      paths            = ["/api/healthcheck"]
      healthcheck_path = "/api/healthcheckz"
      priority         = 3
    }

    hub_frontend = {
      hosts            = ["hub.*"]
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 4
    }

    tea = {
      hosts            = ["tea.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 5
    }

    duty_calculator = {
      paths            = ["/duty-calculator/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 17
    }

    backend_uk = {
      paths            = ["/api/*", "/uk/api/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 20
    }

    backend_xi = {
      paths            = ["/xi/api/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 21
    }

    hub = {
      hosts            = ["new-hub.*"]
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
    signon_preview = {
      hosts            = ["signon.*"]
      healthcheck_path = "/healthcheck/live"
      priority         = 20
    }

    hub_backend_preview = {
      hosts            = ["hub.*"]
      paths            = ["/api/healthcheck"]
      healthcheck_path = "/api/healthcheckz"
      priority         = 40
    }
  }
}
