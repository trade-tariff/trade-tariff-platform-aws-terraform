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
  cache_key_params          = ["as_of"]
}

run "no_carveouts_without_uncached_paths" {
  command = plan

  variables {
    uk_uncached_paths = []
    xi_uncached_paths = []
  }

  assert {
    condition = alltrue([
      length(aws_api_gateway_resource.uk_exceptions) == 0,
      length(aws_api_gateway_method.uk_exceptions) == 0,
      length(aws_api_gateway_integration.uk_exceptions) == 0,
      length(aws_api_gateway_resource.xi_exceptions) == 0,
      length(aws_api_gateway_method.xi_exceptions) == 0,
      length(aws_api_gateway_integration.xi_exceptions) == 0,
    ])
    error_message = "No carveout resources, methods or integrations must be created when the uncached path sets are empty."
  }
}

run "uk_and_xi_carveouts_follow_their_own_path_sets" {
  command = plan

  variables {
    uk_uncached_paths = ["search", "search_suggestions"]
    xi_uncached_paths = ["chemical_substances"]
  }

  assert {
    condition = alltrue([
      keys(aws_api_gateway_resource.uk_exceptions) == ["search", "search_suggestions"],
      keys(aws_api_gateway_method.uk_exceptions) == ["search", "search_suggestions"],
      keys(aws_api_gateway_integration.uk_exceptions) == ["search", "search_suggestions"],
    ])
    error_message = "UK carveouts must have one resource, method and integration for each uk_uncached_paths entry."
  }

  assert {
    condition = alltrue([
      keys(aws_api_gateway_resource.xi_exceptions) == ["chemical_substances"],
      keys(aws_api_gateway_method.xi_exceptions) == ["chemical_substances"],
      keys(aws_api_gateway_integration.xi_exceptions) == ["chemical_substances"],
    ])
    error_message = "XI carveouts must have one resource, method and integration for each xi_uncached_paths entry."
  }

  assert {
    condition     = aws_api_gateway_resource.uk_exceptions["search"].path_part == "search" && aws_api_gateway_resource.xi_exceptions["chemical_substances"].path_part == "chemical_substances"
    error_message = "Each carveout resource path_part must be the uncached path name."
  }
}

run "carveouts_proxy_to_the_matching_backend_path" {
  command = plan

  variables {
    uk_uncached_paths = ["search"]
    xi_uncached_paths = ["search"]
  }

  assert {
    condition     = aws_api_gateway_integration.uk_exceptions["search"].uri == "http://api.example.test/uk/api/search"
    error_message = "A UK carveout must proxy to /uk/api/<path> on the backend."
  }

  assert {
    condition     = aws_api_gateway_integration.xi_exceptions["search"].uri == "http://api.example.test/xi/api/search"
    error_message = "An XI carveout must proxy to /xi/api/<path> on the backend."
  }

  assert {
    condition     = aws_api_gateway_integration.uk_exceptions["search"].type == "HTTP_PROXY" && aws_api_gateway_integration.xi_exceptions["search"].type == "HTTP_PROXY"
    error_message = "Carveout integrations must be HTTP_PROXY integrations."
  }
}

run "carveouts_declare_no_cache_key_query_params" {
  command = plan

  variables {
    uk_uncached_paths = ["search"]
    xi_uncached_paths = ["search"]
  }

  # cache_key_parameters is Optional and Computed, so an unset value is
  # unknown at plan. The method request parameters are known, and they show
  # that the carveouts do not declare the cache key query strings.
  assert {
    condition = alltrue([
      aws_api_gateway_method.uk_exceptions["search"].request_parameters == tomap({ "method.request.path.proxy" = true }),
      aws_api_gateway_method.xi_exceptions["search"].request_parameters == tomap({ "method.request.path.proxy" = true }),
    ])
    error_message = "Carveout methods must not declare cache key query string parameters."
  }
}
