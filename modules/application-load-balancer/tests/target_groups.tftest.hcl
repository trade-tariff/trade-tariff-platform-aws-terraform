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
    backend_uk = {
      healthcheck_path = "/healthcheckz"
      priority         = 10
    }
  }
}

run "names_https_target_groups_from_service_keys_with_dashes" {
  command = plan

  assert {
    condition     = keys(aws_lb_target_group.trade_tariff_https_target_groups) == ["backend_uk"]
    error_message = "One HTTPS target group must be created for each service key."
  }

  assert {
    condition     = aws_lb_target_group.trade_tariff_https_target_groups["backend_uk"].name == "backend-uk-https"
    error_message = "HTTPS target group names must replace underscores with dashes and end in -https."
  }

  assert {
    condition     = aws_lb_target_group.trade_tariff_https_target_groups["backend_uk"].health_check[0].path == "/healthcheckz"
    error_message = "The HTTPS target group health check must use the service healthcheck_path."
  }

  assert {
    condition     = keys(output.target_groups) == ["backend-uk-https"]
    error_message = "The target_groups output must be keyed by target group name."
  }
}

run "sends_https_target_group_traffic_to_the_tls_application_port" {
  command = plan

  variables {
    tls_application_port = 9443
  }

  assert {
    condition     = aws_lb_target_group.trade_tariff_https_target_groups["backend_uk"].port == 9443
    error_message = "HTTPS target groups must use tls_application_port."
  }

  assert {
    condition     = aws_lb_target_group.trade_tariff_https_target_groups["backend_uk"].protocol == "HTTPS"
    error_message = "HTTPS target groups must use the HTTPS protocol."
  }
}

run "creates_http_target_groups_with_default_container_port" {
  command = plan

  variables {
    http_services = {
      feature_flags = {
        healthcheck_path = "/health"
        priority         = 20
      }
    }
  }

  assert {
    condition     = aws_lb_target_group.http_target_groups["feature_flags"].name == "feature-flags-http"
    error_message = "HTTP target group names must replace underscores with dashes and end in -http."
  }

  assert {
    condition     = aws_lb_target_group.http_target_groups["feature_flags"].port == 8000
    error_message = "HTTP target groups must default to container port 8000."
  }

  assert {
    condition     = aws_lb_target_group.http_target_groups["feature_flags"].protocol == "HTTP"
    error_message = "HTTP target groups must use the HTTP protocol."
  }

  assert {
    condition     = aws_lb_target_group.http_target_groups["feature_flags"].health_check[0].protocol == "HTTP"
    error_message = "HTTP target group health checks must use the HTTP protocol."
  }

  assert {
    condition     = keys(output.http_target_groups) == ["feature-flags-http"]
    error_message = "The http_target_groups output must be keyed by target group name."
  }
}

run "uses_the_given_container_port_for_http_target_groups" {
  command = plan

  variables {
    http_services = {
      feature_flags = {
        healthcheck_path = "/health"
        container_port   = 8080
        priority         = 20
      }
    }
  }

  assert {
    condition     = aws_lb_target_group.http_target_groups["feature_flags"].port == 8080
    error_message = "HTTP target groups must use the container_port the caller gives."
  }
}

run "creates_no_http_target_groups_by_default" {
  command = plan

  assert {
    condition     = length(aws_lb_target_group.http_target_groups) == 0
    error_message = "No HTTP target groups must be created when http_services is empty."
  }
}
