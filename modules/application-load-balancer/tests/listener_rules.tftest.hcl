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
      hosts            = ["www.dev.trade-tariff.service.gov.uk"]
      priority         = 10
    }
    backend = {
      healthcheck_path = "/healthcheckz"
      paths            = ["/api/*"]
      priority         = 20
    }
    webhooks = {
      healthcheck_path     = "/healthcheckz"
      paths                = ["/webhooks/*"]
      priority             = 30
      bypass_custom_header = true
    }
  }
}

run "adds_host_and_custom_header_conditions_for_a_service_with_hosts" {
  command = plan

  assert {
    condition     = length(aws_lb_listener_rule.this["frontend"].condition) == 2
    error_message = "A service with hosts and no paths must have a host condition and a custom header condition."
  }

  assert {
    condition     = anytrue([for c in aws_lb_listener_rule.this["frontend"].condition : length(c.host_header) == 1 && one(c.host_header).values == toset(["www.dev.trade-tariff.service.gov.uk"])])
    error_message = "A service with hosts must have a host_header condition with those hosts."
  }

  assert {
    condition     = alltrue([for c in aws_lb_listener_rule.this["frontend"].condition : length(c.path_pattern) == 0])
    error_message = "A service without paths must have no path_pattern condition."
  }

  assert {
    condition     = aws_lb_listener_rule.this["frontend"].priority == 10
    error_message = "The listener rule must use the service priority."
  }
}

run "adds_path_and_custom_header_conditions_for_a_service_with_paths" {
  command = plan

  assert {
    condition     = length(aws_lb_listener_rule.this["backend"].condition) == 2
    error_message = "A service with paths and no hosts must have a path condition and a custom header condition."
  }

  assert {
    condition     = anytrue([for c in aws_lb_listener_rule.this["backend"].condition : length(c.path_pattern) == 1 && one(c.path_pattern).values == toset(["/api/*"])])
    error_message = "A service with paths must have a path_pattern condition with those paths."
  }

  assert {
    condition     = alltrue([for c in aws_lb_listener_rule.this["backend"].condition : length(c.host_header) == 0])
    error_message = "A service without hosts must have no host_header condition."
  }
}

run "requires_the_custom_header_on_services_by_default" {
  command = plan

  assert {
    condition = anytrue([
      for c in aws_lb_listener_rule.this["backend"].condition :
      length(c.http_header) == 1 &&
      one(c.http_header).http_header_name == "X-Origin-Verify" &&
      one(c.http_header).values == toset(["test-secret"])
    ])
    error_message = "A service must require the custom header name and value unless it opts out."
  }
}

run "skips_the_custom_header_when_a_service_bypasses_it" {
  command = plan

  assert {
    condition     = length(aws_lb_listener_rule.this["webhooks"].condition) == 1
    error_message = "A service that bypasses the custom header must only have its path condition."
  }

  assert {
    condition     = alltrue([for c in aws_lb_listener_rule.this["webhooks"].condition : length(c.http_header) == 0])
    error_message = "A service that bypasses the custom header must have no http_header condition."
  }
}

run "always_requires_the_custom_header_on_http_services" {
  command = plan

  variables {
    http_services = {
      feature_flags = {
        healthcheck_path = "/health"
        hosts            = ["flags.dev.trade-tariff.service.gov.uk"]
        priority         = 40
      }
    }
  }

  assert {
    condition     = length(aws_lb_listener_rule.http_services["feature_flags"].condition) == 2
    error_message = "An HTTP service with hosts must have a host condition and a custom header condition."
  }

  assert {
    condition = anytrue([
      for c in aws_lb_listener_rule.http_services["feature_flags"].condition :
      length(c.http_header) == 1 &&
      one(c.http_header).http_header_name == "X-Origin-Verify" &&
      one(c.http_header).values == toset(["test-secret"])
    ])
    error_message = "An HTTP service must always require the custom header."
  }

  assert {
    condition     = anytrue([for c in aws_lb_listener_rule.http_services["feature_flags"].condition : length(c.host_header) == 1 && one(c.host_header).values == toset(["flags.dev.trade-tariff.service.gov.uk"])])
    error_message = "An HTTP service with hosts must have a host_header condition with those hosts."
  }
}

run "routes_gateway_services_by_api_host_on_the_http_listener" {
  command = plan

  variables {
    gateway_services = {
      backend = {
        healthcheck_path = "/healthcheckz"
        paths            = ["/uk/api/*"]
        priority         = 5
      }
    }
  }

  assert {
    condition     = keys(aws_lb_listener_rule.redirect_http_rules) == ["backend"]
    error_message = "One HTTP listener rule must be created for each gateway service."
  }

  assert {
    condition     = anytrue([for c in aws_lb_listener_rule.redirect_http_rules["backend"].condition : length(c.host_header) == 1 && one(c.host_header).values == toset(["api.dev.trade-tariff.service.gov.uk"])])
    error_message = "Gateway service rules must match the host api.<domain_name>."
  }

  assert {
    condition     = anytrue([for c in aws_lb_listener_rule.redirect_http_rules["backend"].condition : length(c.path_pattern) == 1 && one(c.path_pattern).values == toset(["/uk/api/*"])])
    error_message = "Gateway service rules must match the gateway service paths."
  }

  assert {
    condition     = aws_lb_listener_rule.redirect_http_rules["backend"].action[0].type == "forward"
    error_message = "Gateway service rules must forward to the target group."
  }
}

run "omits_the_path_condition_for_gateway_services_without_paths" {
  command = plan

  variables {
    gateway_services = {
      backend = {
        healthcheck_path = "/healthcheckz"
        priority         = 5
      }
    }
  }

  assert {
    condition     = length(aws_lb_listener_rule.redirect_http_rules["backend"].condition) == 1
    error_message = "A gateway service without paths must only have the host condition."
  }
}

run "denies_listed_paths_with_a_403" {
  command = plan

  variables {
    denied_paths = {
      internal = {
        paths    = ["/uk/internal/*", "/xi/internal/*"]
        priority = 1
      }
    }
  }

  assert {
    condition     = aws_lb_listener_rule.denied_paths["internal"].priority == 1
    error_message = "The denied path rule must use the priority the caller gives."
  }

  assert {
    condition     = aws_lb_listener_rule.denied_paths["internal"].action[0].type == "fixed-response"
    error_message = "The denied path rule must return a fixed response."
  }

  assert {
    condition     = aws_lb_listener_rule.denied_paths["internal"].action[0].fixed_response[0].status_code == "403"
    error_message = "The denied path rule must return status 403."
  }

  assert {
    condition     = one(one(aws_lb_listener_rule.denied_paths["internal"].condition).path_pattern).values == toset(["/uk/internal/*", "/xi/internal/*"])
    error_message = "The denied path rule must match the denied paths."
  }
}
