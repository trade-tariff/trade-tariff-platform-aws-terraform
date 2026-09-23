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
  cache_key_params          = ["as_of", "filter.type"]
}

run "caching_is_off_by_default_for_every_method" {
  command = plan

  assert {
    condition     = aws_api_gateway_method_settings.this.method_path == "*/*"
    error_message = "The default method settings must apply to every method."
  }

  assert {
    condition     = aws_api_gateway_method_settings.this.settings[0].caching_enabled == false
    error_message = "Caching must be disabled by default for every method."
  }

  assert {
    condition     = aws_api_gateway_method_settings.this.settings[0].cache_data_encrypted == true
    error_message = "Cached data must be encrypted."
  }

  assert {
    condition     = aws_api_gateway_method_settings.this.settings[0].metrics_enabled == true
    error_message = "Metrics must be enabled for every method."
  }
}

run "only_get_on_the_api_proxy_is_cached" {
  command = plan

  variables {
    long_cache_ttl = 1800
  }

  assert {
    condition     = aws_api_gateway_method_settings.uk_cache.method_path == "uk/api/{proxy+}/GET"
    error_message = "UK caching must apply only to GET on uk/api/{proxy+}."
  }

  assert {
    condition     = aws_api_gateway_method_settings.xi_cache.method_path == "xi/api/{proxy+}/GET"
    error_message = "XI caching must apply only to GET on xi/api/{proxy+}."
  }

  assert {
    condition     = aws_api_gateway_method_settings.uk_cache.settings[0].caching_enabled && aws_api_gateway_method_settings.xi_cache.settings[0].caching_enabled
    error_message = "Caching must be enabled on the UK and XI API proxy GET methods."
  }

  assert {
    condition     = aws_api_gateway_method_settings.uk_cache.settings[0].cache_ttl_in_seconds == 1800 && aws_api_gateway_method_settings.xi_cache.settings[0].cache_ttl_in_seconds == 1800
    error_message = "The UK and XI API proxy caches must use long_cache_ttl."
  }
}

run "api_proxy_cache_key_includes_path_and_query_params" {
  command = plan

  assert {
    condition = aws_api_gateway_integration.uk_proxy.cache_key_parameters == toset([
      "method.request.path.proxy",
      "method.request.querystring.as_of",
      "method.request.querystring.filter.type",
    ])
    error_message = "The UK API proxy cache key must be the proxy path plus every cache_key_params query string."
  }

  assert {
    condition = aws_api_gateway_integration.xi_proxy.cache_key_parameters == toset([
      "method.request.path.proxy",
      "method.request.querystring.as_of",
      "method.request.querystring.filter.type",
    ])
    error_message = "The XI API proxy cache key must be the proxy path plus every cache_key_params query string."
  }
}

run "api_proxy_methods_declare_cache_key_query_params_as_optional" {
  command = plan

  assert {
    condition = aws_api_gateway_method.uk_proxy.request_parameters == tomap({
      "method.request.path.proxy"              = true
      "method.request.querystring.as_of"       = false
      "method.request.querystring.filter.type" = false
    })
    error_message = "The UK API proxy method must require the proxy path and declare each cache key query string as optional."
  }

  assert {
    condition = aws_api_gateway_method.xi_proxy.request_parameters == tomap({
      "method.request.path.proxy"              = true
      "method.request.querystring.as_of"       = false
      "method.request.querystring.filter.type" = false
    })
    error_message = "The XI API proxy method must require the proxy path and declare each cache key query string as optional."
  }
}

run "api_proxy_cache_key_is_only_the_path_without_query_params" {
  command = plan

  variables {
    cache_key_params = []
  }

  assert {
    condition     = aws_api_gateway_integration.uk_proxy.cache_key_parameters == toset(["method.request.path.proxy"])
    error_message = "The UK API proxy cache key must be only the proxy path when cache_key_params is empty."
  }

  assert {
    condition     = aws_api_gateway_integration.xi_proxy.cache_key_parameters == toset(["method.request.path.proxy"])
    error_message = "The XI API proxy cache key must be only the proxy path when cache_key_params is empty."
  }
}
