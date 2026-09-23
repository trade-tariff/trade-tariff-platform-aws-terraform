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

run "no_authorizer_is_created_when_disabled" {
  command = plan

  assert {
    condition     = length(aws_api_gateway_authorizer.this) == 0
    error_message = "No authorizer must be created when authorizer_enabled is false."
  }

  assert {
    condition     = aws_api_gateway_rest_api.this.api_key_source == "HEADER"
    error_message = "The API key source must be HEADER when the authorizer is disabled."
  }

  assert {
    condition = alltrue([
      aws_api_gateway_method.uk.authorization == "NONE",
      aws_api_gateway_method.uk_fallback_proxy.authorization == "NONE",
      aws_api_gateway_method.uk_proxy.authorization == "NONE",
      aws_api_gateway_method.uk_exceptions["search"].authorization == "NONE",
      aws_api_gateway_method.xi.authorization == "NONE",
      aws_api_gateway_method.xi_fallback_proxy.authorization == "NONE",
      aws_api_gateway_method.xi_proxy.authorization == "NONE",
      aws_api_gateway_method.xi_exceptions["search"].authorization == "NONE",
    ])
    error_message = "Every UK and XI method must use NONE authorization when the authorizer is disabled."
  }

  assert {
    condition = alltrue([
      aws_api_gateway_method.uk.authorizer_id == null,
      aws_api_gateway_method.uk_fallback_proxy.authorizer_id == null,
      aws_api_gateway_method.uk_proxy.authorizer_id == null,
      aws_api_gateway_method.uk_exceptions["search"].authorizer_id == null,
      aws_api_gateway_method.xi.authorizer_id == null,
      aws_api_gateway_method.xi_fallback_proxy.authorizer_id == null,
      aws_api_gateway_method.xi_proxy.authorizer_id == null,
      aws_api_gateway_method.xi_exceptions["search"].authorizer_id == null,
    ])
    error_message = "No UK or XI method must reference an authorizer when the authorizer is disabled."
  }
}

run "authorizer_protects_every_uk_and_xi_method_when_enabled" {
  command = plan

  variables {
    authorizer_enabled           = true
    authorizer_lambda_invoke_arn = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-2:123456789012:function:api-authorizer/invocations"
  }

  assert {
    condition     = length(aws_api_gateway_authorizer.this) == 1
    error_message = "One authorizer must be created when authorizer_enabled is true."
  }

  assert {
    condition     = aws_api_gateway_authorizer.this[0].type == "REQUEST"
    error_message = "The authorizer must be a REQUEST authorizer."
  }

  assert {
    condition     = aws_api_gateway_authorizer.this[0].name == "api-authorizer-test"
    error_message = "The authorizer name must default to api-authorizer-<environment> when authorizer_name is null."
  }

  assert {
    condition     = aws_api_gateway_rest_api.this.api_key_source == "AUTHORIZER"
    error_message = "The API key source must be AUTHORIZER when the authorizer is enabled."
  }

  assert {
    condition = alltrue([
      aws_api_gateway_method.uk.authorization == "CUSTOM",
      aws_api_gateway_method.uk_fallback_proxy.authorization == "CUSTOM",
      aws_api_gateway_method.uk_proxy.authorization == "CUSTOM",
      aws_api_gateway_method.uk_exceptions["search"].authorization == "CUSTOM",
      aws_api_gateway_method.xi.authorization == "CUSTOM",
      aws_api_gateway_method.xi_fallback_proxy.authorization == "CUSTOM",
      aws_api_gateway_method.xi_proxy.authorization == "CUSTOM",
      aws_api_gateway_method.xi_exceptions["search"].authorization == "CUSTOM",
    ])
    error_message = "Every UK and XI method must use CUSTOM authorization when the authorizer is enabled."
  }
}

run "authorizer_uses_given_name" {
  command = plan

  variables {
    authorizer_enabled           = true
    authorizer_name              = "custom-authorizer"
    authorizer_lambda_invoke_arn = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-2:123456789012:function:api-authorizer/invocations"
  }

  assert {
    condition     = aws_api_gateway_authorizer.this[0].name == "custom-authorizer"
    error_message = "The authorizer must use authorizer_name when it is set."
  }
}

run "uk_and_xi_methods_always_require_an_api_key" {
  command = plan

  assert {
    condition = alltrue([
      aws_api_gateway_method.uk.api_key_required,
      aws_api_gateway_method.uk_fallback_proxy.api_key_required,
      aws_api_gateway_method.uk_proxy.api_key_required,
      aws_api_gateway_method.uk_exceptions["search"].api_key_required,
      aws_api_gateway_method.xi.api_key_required,
      aws_api_gateway_method.xi_fallback_proxy.api_key_required,
      aws_api_gateway_method.xi_proxy.api_key_required,
      aws_api_gateway_method.xi_exceptions["search"].api_key_required,
    ])
    error_message = "Every UK and XI method must require an API key."
  }
}

run "docs_redirect_methods_are_public" {
  command = plan

  variables {
    authorizer_enabled           = true
    authorizer_lambda_invoke_arn = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-2:123456789012:function:api-authorizer/invocations"
  }

  assert {
    condition     = aws_api_gateway_method.root_redirect.authorization == "NONE" && aws_api_gateway_method.proxy.authorization == "NONE"
    error_message = "The docs redirect methods must not use the authorizer, even when it is enabled."
  }

  assert {
    condition     = aws_api_gateway_method.proxy.api_key_required == false
    error_message = "The catch-all docs redirect method must not require an API key."
  }
}
