resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.xi.path_part,

      aws_api_gateway_method.xi.http_method,
      aws_api_gateway_method.xi.authorization,
      var.authorizer_enabled ? aws_api_gateway_method.xi.authorizer_id : null,

      aws_api_gateway_integration.xi.type,
      aws_api_gateway_integration.xi.uri,
      aws_api_gateway_integration.xi.request_parameters,

      aws_api_gateway_resource.xi_fallback_proxy.path_part,

      aws_api_gateway_method.xi_fallback_proxy.http_method,
      aws_api_gateway_method.xi_fallback_proxy.authorization,
      aws_api_gateway_method.xi_fallback_proxy.request_parameters,
      var.authorizer_enabled ? aws_api_gateway_method.xi_fallback_proxy.authorizer_id : null,

      aws_api_gateway_integration.xi_fallback_proxy.type,
      aws_api_gateway_integration.xi_fallback_proxy.uri,
      aws_api_gateway_integration.xi_fallback_proxy.request_parameters,

      aws_api_gateway_resource.xi_api.path_part,
      aws_api_gateway_resource.xi_proxy.path_part,

      aws_api_gateway_method.xi_proxy.http_method,
      aws_api_gateway_method.xi_proxy.authorization,
      aws_api_gateway_method.xi_proxy.request_parameters,
      var.authorizer_enabled ? aws_api_gateway_method.xi_proxy.authorizer_id : null,

      aws_api_gateway_integration.xi_proxy.type,
      aws_api_gateway_integration.xi_proxy.uri,
      aws_api_gateway_integration.xi_proxy.request_parameters,

      aws_api_gateway_resource.uk.path_part,

      aws_api_gateway_method.uk.http_method,
      aws_api_gateway_method.uk.authorization,
      var.authorizer_enabled ? aws_api_gateway_method.uk.authorizer_id : null,

      aws_api_gateway_integration.uk.type,
      aws_api_gateway_integration.uk.uri,
      aws_api_gateway_integration.uk.request_parameters,

      aws_api_gateway_resource.uk_fallback_proxy.path_part,

      aws_api_gateway_method.uk_fallback_proxy.http_method,
      aws_api_gateway_method.uk_fallback_proxy.authorization,
      aws_api_gateway_method.uk_fallback_proxy.request_parameters,
      var.authorizer_enabled ? aws_api_gateway_method.uk_fallback_proxy.authorizer_id : null,

      aws_api_gateway_integration.uk_fallback_proxy.type,
      aws_api_gateway_integration.uk_fallback_proxy.uri,
      aws_api_gateway_integration.uk_fallback_proxy.request_parameters,

      aws_api_gateway_resource.uk_api.path_part,
      aws_api_gateway_resource.uk_proxy.path_part,

      aws_api_gateway_method.uk_proxy.http_method,
      aws_api_gateway_method.uk_proxy.authorization,
      aws_api_gateway_method.uk_proxy.request_parameters,
      var.authorizer_enabled ? aws_api_gateway_method.uk_proxy.authorizer_id : null,

      aws_api_gateway_integration.uk_proxy.type,
      aws_api_gateway_integration.uk_proxy.uri,
      aws_api_gateway_integration.uk_proxy.request_parameters,

      aws_api_gateway_resource.proxy.path_part,

      aws_api_gateway_method.proxy.http_method,
      aws_api_gateway_method.proxy.request_parameters,

      aws_api_gateway_integration.proxy_redirect.uri,
      aws_api_gateway_integration.proxy_redirect.request_parameters,

      keys(aws_api_gateway_resource.uk_exceptions),
      keys(aws_api_gateway_resource.xi_exceptions),

      var.cache_key_params,
      var.authorizer_enabled,
      var.authorizer_name,
      var.authorizer_identity_source,
      var.authorizer_result_ttl_in_seconds,
      aws_api_gateway_rest_api.this.api_key_source,
      var.authorizer_enabled ? aws_api_gateway_authorizer.this[0].authorizer_uri : null,

      aws_api_gateway_gateway_response.unauthorized.response_templates,
      aws_api_gateway_gateway_response.access_denied.response_templates,
      aws_api_gateway_gateway_response.throttled.response_templates,

      aws_api_gateway_integration.root_redirect.request_templates,
      aws_api_gateway_integration_response.root_redirect.response_parameters
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
