resource "aws_api_gateway_rest_api" "this" {
  name        = "api-${var.environment}"
  description = "Main API Gateway for trade-tariff ${var.environment} (ALB Proxy)"
  endpoint_configuration { types = ["REGIONAL"] }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.environment

  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "api-alb-vpc-link-${var.environment}"
  security_group_ids = var.security_group_ids
  subnet_ids         = var.private_subnet_ids
}

# ------------------------------------------------------------------------------
# Default cache settings (off)
# ------------------------------------------------------------------------------

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    caching_enabled      = false
    logging_level        = var.log_level
    cache_data_encrypted = true
  }
}

# ------------------------------------------------------------------------------
# XI cache settings (long)
# ------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "xi" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "xi"
}

resource "aws_api_gateway_resource" "xi_api" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.xi.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "xi_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.xi_api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "xi_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.xi_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = merge(
    { "method.request.path.proxy" = true },
    { for p in var.cache_key_params : "method.request.querystring.${p}" => false }
  )
}

resource "aws_api_gateway_integration" "xi_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.xi_proxy.id
  http_method             = aws_api_gateway_method.xi_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"

  uri                = "http://api.${var.domain_name}/xi/api/{proxy}"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  integration_target = var.lb_arn

  cache_key_parameters = concat(
    ["method.request.path.proxy"],
    [for p in var.cache_key_params : "method.request.querystring.${p}"]
  )

  request_parameters = {
    "integration.request.path.proxy"                         = "method.request.path.proxy"
    "integration.request.header.${var.alb_secret_header[0]}" = "'${var.alb_secret_header[1]}'"
  }
}

resource "aws_api_gateway_method_settings" "xi_cache" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "${aws_api_gateway_resource.xi.path_part}/${aws_api_gateway_resource.xi_api.path_part}/{proxy+}/GET"

  settings {
    caching_enabled      = true
    cache_ttl_in_seconds = var.long_cache_ttl
  }
}

# ------------------------------------------------------------------------------
# UK cache settings (long)
# ------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "uk" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "uk"
}

resource "aws_api_gateway_resource" "uk_api" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.uk.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "uk_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.uk_api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "uk_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.uk_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = merge({
    "method.request.path.proxy" = true
    },
    { for p in var.cache_key_params : "method.request.querystring.${p}" => false }
  )
}

resource "aws_api_gateway_integration" "uk_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.uk_proxy.id
  http_method             = aws_api_gateway_method.uk_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"

  uri                = "http://api.${var.domain_name}/uk/api/{proxy}"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  integration_target = var.lb_arn

  cache_key_parameters = concat(
    ["method.request.path.proxy"],
    [for p in var.cache_key_params : "method.request.querystring.${p}"]
  )

  request_parameters = {
    "integration.request.path.proxy"                         = "method.request.path.proxy"
    "integration.request.header.${var.alb_secret_header[0]}" = "'${var.alb_secret_header[1]}'"
  }
}

resource "aws_api_gateway_method_settings" "uk_cache" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "${aws_api_gateway_resource.uk.path_part}/${aws_api_gateway_resource.uk_api.path_part}/{proxy+}/GET"

  settings {
    caching_enabled      = true
    cache_ttl_in_seconds = var.long_cache_ttl
  }
}

# ------------------------------------------------------------------------------
# CACHE EXCEPTIONS - uncached carveouts
# ------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "uk_exceptions" {
  for_each    = var.uk_uncached_paths
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.uk_api.id
  path_part   = each.key
}

resource "aws_api_gateway_method" "uk_exceptions" {
  for_each         = aws_api_gateway_resource.uk_exceptions
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = each.value.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "uk_exceptions" {
  for_each                = aws_api_gateway_resource.uk_exceptions
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.id
  http_method             = aws_api_gateway_method.uk_exceptions[each.key].http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"

  uri                = "http://api.${var.domain_name}/uk/api/${each.value.path_part}"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  integration_target = var.lb_arn

  request_parameters = {
    "integration.request.path.proxy"                         = "method.request.path.proxy"
    "integration.request.header.${var.alb_secret_header[0]}" = "'${var.alb_secret_header[1]}'"
  }

}

resource "aws_api_gateway_resource" "xi_exceptions" {
  for_each    = var.xi_uncached_paths
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.xi_api.id
  path_part   = each.key
}

resource "aws_api_gateway_method" "xi_exceptions" {
  for_each         = aws_api_gateway_resource.xi_exceptions
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = each.value.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "xi_exceptions" {
  for_each                = aws_api_gateway_resource.xi_exceptions
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.id
  http_method             = aws_api_gateway_method.xi_exceptions[each.key].http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"

  uri                = "http://api.${var.domain_name}/xi/api/${each.value.path_part}"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  integration_target = var.lb_arn

  request_parameters = {
    "integration.request.path.proxy"                         = "method.request.path.proxy"
    "integration.request.header.${var.alb_secret_header[0]}" = "'${var.alb_secret_header[1]}'"
  }
}

# ---------------------------------------------------------------------------------------
# REDIRECT OLD REQUESTS TO MOVED DOCS SITE (applies to everything not /uk/api or /xi/api)
# ---------------------------------------------------------------------------------------
resource "aws_api_gateway_method" "root_redirect" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "root_redirect" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.root_redirect.http_method
  status_code = "301"

  response_parameters = {
    "method.response.header.Location" = true
  }
}

resource "aws_api_gateway_integration" "root_redirect" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.root_redirect.http_method
  type        = "MOCK"


  request_templates = {
    "application/json" = jsonencode({ statusCode = 301 })
    "text/html"        = jsonencode({ statusCode = 301 })
    "text/plain"       = jsonencode({ statusCode = 301 })
  }
}

resource "aws_api_gateway_integration_response" "root_redirect" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.root_redirect.http_method
  status_code = aws_api_gateway_method_response.root_redirect.status_code

  response_parameters = {
    "method.response.header.Location" = "'https://docs.${var.domain_name}/'"
  }

  depends_on = [aws_api_gateway_integration.root_redirect]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method_response" "proxy_redirect" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "301"

  response_parameters = {
    "method.response.header.Location" = true
  }
}

resource "aws_api_gateway_integration" "proxy_redirect" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  type        = "MOCK"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/json'"
  }

  request_templates = {
    "application/json" = jsonencode({ statusCode = 301 })
    "text/html"        = jsonencode({ statusCode = 301 })
    "text/plain"       = jsonencode({ statusCode = 301 })
  }
}

resource "aws_api_gateway_integration_response" "proxy_redirect" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.proxy_redirect.status_code

  response_parameters = {
    # NOTE: VTL templates fail to forward location so we redirect to the base docs URL, here.
    "method.response.header.Location" = "'https://docs.${var.domain_name}/'"
  }

  depends_on = [aws_api_gateway_integration.proxy_redirect]
}
