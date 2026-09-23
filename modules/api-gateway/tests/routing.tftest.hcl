mock_provider "aws" {}

variables {
  environment               = "test"
  domain_name               = "example.test"
  validated_certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  zone_id                   = "Z0000000000000000000"
  security_group_ids        = ["sg-00000000000000000"]
  private_subnet_ids        = ["subnet-00000000000000000", "subnet-11111111111111111"]
  lb_arn                    = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/app/test/0000000000000000"
  alb_secret_header         = ["X-Origin-Secret", "test-secret"]
  uk_uncached_paths         = ["search"]
  xi_uncached_paths         = ["search"]
}

run "uk_paths_proxy_to_the_uk_backend" {
  command = plan

  assert {
    condition     = aws_api_gateway_integration.uk.uri == "http://api.example.test/uk"
    error_message = "/uk must proxy to /uk on the backend."
  }

  assert {
    condition     = aws_api_gateway_integration.uk_fallback_proxy.uri == "http://api.example.test/uk/{proxy}"
    error_message = "/uk/{proxy+} must proxy to /uk/{proxy} on the backend."
  }

  assert {
    condition     = aws_api_gateway_integration.uk_proxy.uri == "http://api.example.test/uk/api/{proxy}"
    error_message = "/uk/api/{proxy+} must proxy to /uk/api/{proxy} on the backend."
  }
}

run "xi_paths_proxy_to_the_xi_backend" {
  command = plan

  assert {
    condition     = aws_api_gateway_integration.xi.uri == "http://api.example.test/xi"
    error_message = "/xi must proxy to /xi on the backend."
  }

  assert {
    condition     = aws_api_gateway_integration.xi_fallback_proxy.uri == "http://api.example.test/xi/{proxy}"
    error_message = "/xi/{proxy+} must proxy to /xi/{proxy} on the backend."
  }

  assert {
    condition     = aws_api_gateway_integration.xi_proxy.uri == "http://api.example.test/xi/api/{proxy}"
    error_message = "/xi/api/{proxy+} must proxy to /xi/api/{proxy} on the backend."
  }
}

run "proxy_paths_forward_the_proxy_path" {
  command = plan

  assert {
    condition = alltrue([
      aws_api_gateway_integration.uk_fallback_proxy.request_parameters["integration.request.path.proxy"] == "method.request.path.proxy",
      aws_api_gateway_integration.uk_proxy.request_parameters["integration.request.path.proxy"] == "method.request.path.proxy",
      aws_api_gateway_integration.xi_fallback_proxy.request_parameters["integration.request.path.proxy"] == "method.request.path.proxy",
      aws_api_gateway_integration.xi_proxy.request_parameters["integration.request.path.proxy"] == "method.request.path.proxy",
    ])
    error_message = "Every {proxy+} integration must forward the proxy path to the backend."
  }
}

run "every_backend_integration_sends_the_alb_secret_header" {
  command = plan

  assert {
    condition = alltrue([
      for request_parameters in [
        aws_api_gateway_integration.uk.request_parameters,
        aws_api_gateway_integration.uk_fallback_proxy.request_parameters,
        aws_api_gateway_integration.uk_proxy.request_parameters,
        aws_api_gateway_integration.uk_exceptions["search"].request_parameters,
        aws_api_gateway_integration.xi.request_parameters,
        aws_api_gateway_integration.xi_fallback_proxy.request_parameters,
        aws_api_gateway_integration.xi_proxy.request_parameters,
        aws_api_gateway_integration.xi_exceptions["search"].request_parameters,
      ] : lookup(request_parameters, "integration.request.header.X-Origin-Secret", null) == "'test-secret'"
    ])
    error_message = "Every backend integration must send the ALB secret header as a quoted static value."
  }
}

run "every_backend_integration_goes_through_the_vpc_link" {
  command = plan

  assert {
    condition = alltrue([
      for integration in [
        aws_api_gateway_integration.uk,
        aws_api_gateway_integration.uk_fallback_proxy,
        aws_api_gateway_integration.uk_proxy,
        aws_api_gateway_integration.uk_exceptions["search"],
        aws_api_gateway_integration.xi,
        aws_api_gateway_integration.xi_fallback_proxy,
        aws_api_gateway_integration.xi_proxy,
        aws_api_gateway_integration.xi_exceptions["search"],
      ] : integration.connection_type == "VPC_LINK" && integration.integration_target == var.lb_arn
    ])
    error_message = "Every backend integration must reach the ALB through the VPC link."
  }
}

run "other_paths_redirect_to_the_docs_site" {
  command = plan

  assert {
    condition     = aws_api_gateway_integration_response.root_redirect.response_parameters["method.response.header.Location"] == "'https://docs.example.test/'"
    error_message = "The root path must redirect to the docs site."
  }

  assert {
    condition     = aws_api_gateway_integration_response.proxy_redirect.response_parameters["method.response.header.Location"] == "'https://docs.example.test/'"
    error_message = "Paths outside /uk and /xi must redirect to the docs site."
  }

  assert {
    condition     = aws_api_gateway_method_response.root_redirect.status_code == "301" && aws_api_gateway_method_response.proxy_redirect.status_code == "301"
    error_message = "Docs redirects must be permanent (301)."
  }

  assert {
    condition     = aws_api_gateway_integration.root_redirect.type == "MOCK" && aws_api_gateway_integration.proxy_redirect.type == "MOCK"
    error_message = "Docs redirects must be answered by API Gateway and not reach the backend."
  }
}

run "custom_domain_is_the_api_subdomain" {
  command = plan

  assert {
    condition     = aws_api_gateway_domain_name.api.domain_name == "api.example.test"
    error_message = "The custom domain must be api.<domain_name>."
  }

  assert {
    condition     = aws_api_gateway_base_path_mapping.api.domain_name == "api.example.test" && aws_api_gateway_base_path_mapping.api.stage_name == "test"
    error_message = "The base path mapping must map the api.<domain_name> domain to the environment stage."
  }

  assert {
    condition     = aws_route53_record.api.name == "api.example.test" && aws_route53_record.api.type == "A"
    error_message = "An alias A record must point api.<domain_name> at the custom domain."
  }
}
