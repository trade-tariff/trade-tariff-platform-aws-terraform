mock_provider "aws" {}

variables {
  alb_name              = "trade-tariff-alb-development"
  alb_security_group_id = "sg-00000000000000000"
  certificate_arn       = "arn:aws:acm:eu-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  public_subnet_ids     = ["subnet-00000000000000000", "subnet-11111111111111111"]
  vpc_id                = "vpc-00000000000000000"
  domain_name           = "dev.trade-tariff.service.gov.uk"

  custom_header = {
    name  = "X-Origin-Verify"
    value = "test-secret"
  }

  services = {
    frontend = {
      healthcheck_path = "/healthcheckz"
      priority         = 10
    }
  }
}

run "protects_the_load_balancer_by_default" {
  command = plan

  assert {
    condition     = aws_lb.application_load_balancer.enable_deletion_protection == true
    error_message = "Deletion protection must be on by default."
  }

  assert {
    condition     = aws_lb.application_load_balancer.drop_invalid_header_fields == true
    error_message = "The load balancer must drop invalid header fields."
  }
}

run "redirects_plain_http_to_https" {
  command = plan

  assert {
    condition     = aws_lb_listener.redirect_http.port == 80
    error_message = "The redirect listener must listen on port 80."
  }

  assert {
    condition     = aws_lb_listener.redirect_http.default_action[0].type == "redirect"
    error_message = "The port 80 listener must redirect by default."
  }

  assert {
    condition = (
      aws_lb_listener.redirect_http.default_action[0].redirect[0].protocol == "HTTPS" &&
      aws_lb_listener.redirect_http.default_action[0].redirect[0].port == "443" &&
      aws_lb_listener.redirect_http.default_action[0].redirect[0].status_code == "HTTP_301"
    )
    error_message = "The port 80 listener must permanently redirect to HTTPS on port 443."
  }
}

run "denies_unmatched_https_requests" {
  command = plan

  assert {
    condition     = aws_lb_listener.trade_tariff_listeners.default_action[0].type == "fixed-response"
    error_message = "The HTTPS listener must return a fixed response when no rule matches."
  }

  assert {
    condition     = aws_lb_listener.trade_tariff_listeners.default_action[0].fixed_response[0].status_code == "403"
    error_message = "The HTTPS listener must return 403 when no rule matches."
  }

  assert {
    condition     = aws_lb_listener.trade_tariff_listeners.ssl_policy == "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
    error_message = "The HTTPS listener must use the TLS 1.2+/1.3 post-quantum SSL policy."
  }
}
