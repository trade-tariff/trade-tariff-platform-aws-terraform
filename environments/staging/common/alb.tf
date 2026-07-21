module "alb" {
  source                = "../../../modules/application-load-balancer/"
  alb_name              = "trade-tariff-alb-${var.environment}"
  alb_security_group_id = module.alb-security-group.alb_security_group_id
  certificate_arn       = module.acm_origin.validated_certificate_arn
  public_subnet_ids     = data.terraform_remote_state.base.outputs.public_subnet_ids
  vpc_id                = data.terraform_remote_state.base.outputs.vpc_id
  domain_name           = var.domain_name

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

    identity = {
      hosts            = ["id.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 10
    }

    backend_xi = {
      paths = [
        "/xi/admin*",
        "/xi/api/*",
        "/xi/users*",
      ]
      healthcheck_path = "/healthcheckz"
      priority         = 23
    }

    backend_uk = {
      paths = [
        "/api/*",
        "/uk/admin*",
        "/uk/api*",
        "/uk/user*",
      ]
      healthcheck_path = "/healthcheckz"
      priority         = 24
    }

    hub = {
      hosts            = ["hub.*"]
      healthcheck_path = "/healthcheckz"
      priority         = 25
    }

    mcp = {
      hosts                = ["mcp.*"]
      healthcheck_path     = "/healthcheckz"
      priority             = 26
      bypass_custom_header = true
    }

    ai_eval = {
      hosts                = ["eval.*"]
      healthcheck_path     = "/healthcheckz"
      priority             = 27
      bypass_custom_header = true
    }

    frontend = {
      paths            = ["/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 99 # Most generic rule for frontend should match last
    }
  }

  http_services = {
    flagsmith = {
      hosts            = ["flags.*"]
      healthcheck_path = "/health"
      container_port   = 8000
      priority         = 21
    }

    flagsmith_edge = {
      hosts            = ["flags-edge.*"]
      healthcheck_path = "/proxy/health"
      container_port   = 8000
      priority         = 22
    }
  }

  gateway_services = {
    backend_xi = {
      paths            = ["/xi/api/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 1
    }

    backend_uk = {
      paths            = ["/uk/api/*"]
      healthcheck_path = "/healthcheckz"
      priority         = 2
    }
  }
}

resource "aws_lb_listener_certificate" "mcp" {
  listener_arn    = module.alb.https_listener_arn
  certificate_arn = module.acm_london.validated_certificate_arn
}
