data "external" "latest_auth_lambda_version" {
  program = ["bash", "../../../${path.root}/bin/latest-lambda-version-arn"]

  query = {
    function_name = "viewer-request-${var.environment}-auth"
    region        = "us-east-1"
  }
}

data "external" "latest_response_lambda_version" {
  program = ["bash", "../../../${path.root}/bin/latest-lambda-version-arn"]

  query = {
    function_name = "viewer-request-${var.environment}-response"
    region        = "us-east-1"
  }
}

locals {
  edge_functions_enabled = false
  lambda_assoc = local.edge_functions_enabled ? {
    "viewer-request" = {
      lambda_arn = data.external.latest_auth_lambda_version.result.arn
    },
    "viewer-response" = {
      lambda_arn = data.external.latest_response_lambda_version.result.arn
    }
  } : {}
}

module "cdn" {
  source = "../../../modules/cloudfront"

  aliases = [
    var.domain_name,
    "admin.${var.domain_name}",
    "hub.${var.domain_name}",
    "id.${var.domain_name}",
    "tea.${var.domain_name}",
  ]

  create_alias    = true
  route53_zone_id = data.aws_route53_zone.this.id
  comment         = "${title(var.environment)} CDN"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  web_acl_id = module.waf.web_acl_id

  logging_config = {
    bucket = module.logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront/${var.environment}"
  }

  origin = {
    alb = {
      domain_name = local.origin_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }

      custom_header = [{
        name  = random_password.origin_header[0].result
        value = random_password.origin_header[1].result
      }]
    }
  }

  # NOTE: More specific paths should be listed first, as they are evaluated in order
  #       where the first matching path is used and the policy is applied.
  cache_behaviors = [
    {
      name                        = "xi_api_spimm"
      path_pattern                = "/xi/api/v2/green_lanes/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.short_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "xi_api_spimm_unversioned"
      path_pattern                = "/xi/api/green_lanes/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.short_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # Exchange rate endpoints
    {
      name                        = "uk_api_exchange_rates"
      path_pattern                = "/uk/api/v2/exchange_rates/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.medium_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "uk_api_exchange_rates_unversioned"
      path_pattern                = "/uk/api/exchange_rates/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.medium_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "default_api_exchange_rates"
      path_pattern                = "/api/v2/exchange_rates/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.medium_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # Search reference endpoints
    {
      name                        = "xi_api_search_references"
      path_pattern                = "/xi/api/search_references"
      target_origin_id            = "alb"
      cache_policy_id             = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "uk_api_search_references"
      path_pattern                = "/uk/api/search_references"
      target_origin_id            = "alb"
      cache_policy_id             = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # News endpoints
    {
      name                        = "uk_api_news"
      path_pattern                = "/uk/api/news*"
      target_origin_id            = "alb"
      cache_policy_id             = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # Live Issues endpoints
    {
      name                        = "uk_api_live_issues_unversioned"
      path_pattern                = "/uk/api/live_issues*"
      target_origin_id            = "alb"
      cache_policy_id             = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # Healthcheck endpoints
    {
      name                       = "xi_api_healthcheck"
      path_pattern               = "/xi/api/healthcheck"
      target_origin_id           = "alb"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "uk_api_healthcheck"
      path_pattern               = "/uk/api/healthcheck"
      target_origin_id           = "alb"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },

    # BROADER API PATTERNS (must come after specific endpoints)
    {
      name                        = "xi_api"
      path_pattern                = "/xi/api/v2/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "uk_api"
      path_pattern                = "/uk/api/v2/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "default_api"
      path_pattern                = "/api/v2/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # V1 API endpoints
    {
      name                        = "xi_v1_api"
      path_pattern                = "/xi/api/v1/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "uk_v1_api"
      path_pattern                = "/uk/api/v1/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "default_v1_api"
      path_pattern                = "/api/v1/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # V1/V2 API endpoints without version in the path
    {
      name                        = "xi_api_unversioned"
      path_pattern                = "/xi/api/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },
    {
      name                        = "uk_api_unversioned"
      path_pattern                = "/uk/api/*"
      target_origin_id            = "alb"
      cache_policy_id             = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id    = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id  = aws_cloudfront_response_headers_policy.this.id
      lambda_function_association = local.lambda_assoc
    },

    # Static assets (can be anywhere in order since they're distinct patterns)
    {
      name                       = "assets"
      path_pattern               = "/assets/*"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "govuk_frontend"
      path_pattern               = "/govuk-frontend*"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "govuk_publishing_components"
      path_pattern               = "/govuk_publishing_components*"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "images"
      path_pattern               = "*images/*"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "js"
      path_pattern               = "*.js"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "css"
      path_pattern               = "*.css"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "maps"
      path_pattern               = "*.map"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
    {
      name                       = "pngs"
      path_pattern               = "*.png"
      target_origin_id           = "alb"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },

    # DEFAULT BEHAVIOR (no path_pattern)
    {
      name                       = "default"
      target_origin_id           = "alb"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
  ]

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}


module "api_cdn" {
  source = "../../../modules/cloudfront"

  aliases             = ["api.${var.domain_name}"]
  create_alias        = true
  route53_zone_id     = data.aws_route53_zone.this.id
  comment             = "API Docs ${title(var.environment)} CDN"
  default_root_object = "index.html"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  web_acl_id = module.waf.web_acl_id

  logging_config = {
    bucket = module.logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront/${var.environment}"
  }

  origin = {
    api = {
      domain_name              = aws_s3_bucket.this["api-docs"].bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "api"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
  ]

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}

module "reporting_cdn" {
  source = "../../../modules/cloudfront"

  aliases         = ["reporting.${var.domain_name}"]
  create_alias    = true
  route53_zone_id = data.aws_route53_zone.this.id
  comment         = "${title(var.environment)} Reporting CDN"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  web_acl_id = module.waf.web_acl_id

  logging_config = {
    bucket = module.logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront/${var.environment}"
  }

  origin = {
    reporting = {
      domain_name              = aws_s3_bucket.this["reporting"].bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "reporting"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
  ]

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}

module "backups_cdn" {
  source = "../../../modules/cloudfront"

  aliases         = ["dumps.${var.domain_name}"]
  create_alias    = true
  route53_zone_id = data.aws_route53_zone.this.id
  comment         = "${title(var.environment)} Backups CDN"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  web_acl_id = module.waf.web_acl_id

  logging_config = {
    bucket = module.logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront/${var.environment}"
  }

  origin = {
    dumps = {
      domain_name              = aws_s3_bucket.this["database-backups"].bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "dumps"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
      function_association = {
        "viewer-request" = {
          function_arn = aws_cloudfront_function.basic_auth.arn
        }
      }
    }
  ]

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}

resource "aws_cloudfront_function" "basic_auth" {
  name    = "backups-basic-auth"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = local.cloudfront_auth
}

module "tech_docs_cdn" {
  source = "../../../modules/cloudfront"

  aliases             = ["docs.${var.domain_name}"]
  create_alias        = true
  route53_zone_id     = data.aws_route53_zone.this.id
  comment             = "${title(var.environment)} Tech Docs CDN"
  default_root_object = "index.html"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  logging_config = {
    bucket = module.logs.s3_bucket_bucket_domain_name
    prefix = "cloudfront/${var.environment}"
  }

  origin = {
    docs = {
      domain_name              = aws_s3_bucket.this["tech-docs"].bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "docs"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
  ]

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}
