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

    backend_xi = {
      paths = [
        "/xi/api/*"
      ]
      healthcheck_path = "/healthcheckz"
      priority         = 23
    }

    backend_uk = {
      paths = [
        "/api/*",
        "/uk/api/*",
        "/uk/user/*",
      ]
      healthcheck_path = "/healthcheckz"
      priority         = 24
    }

    hub = {
      hosts            = ["hub.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 25
    }

    frontend = {
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 99 # Most generic rule for frontend should match last
    }
  }
}
