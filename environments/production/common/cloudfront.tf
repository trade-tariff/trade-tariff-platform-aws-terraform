module "cdn" {
  source = "../../../modules/cloudfront"

  aliases = [
    var.domain_name,
    "admin.${var.domain_name}",
    "hub.${var.domain_name}",
    "id.${var.domain_name}",
    "tea.${var.domain_name}",
    "www.${var.domain_name}",
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
  cache_behavior = {
    # Static assets are fingerprinted and cached for a long time
    assets = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "/assets/*"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    js = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "*.js"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    css = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "*.css"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    maps = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "*.map"
      cache_policy_id            = aws_cloudfront_cache_policy.very_very_long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    images = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "*images/*"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    pngs = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "*.png"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    govuk_frontend = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "/govuk-frontend*"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    govuk_publishing_components = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = "/govuk_publishing_components*"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # Green lanes/SPIMM endpoints
    xi_api_spimm = {
      target_origin_id           = "alb"
      path_pattern               = "/xi/api/v2/green_lanes/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.short_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    uk_api_spimm = {
      target_origin_id           = "alb"
      path_pattern               = "/uk/api/v2/green_lanes/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.short_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    default_api_spimm = {
      target_origin_id           = "alb"
      path_pattern               = "/api/v2/green_lanes/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.short_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # Exchange rate endpoints
    xi_api_exchange_rates = {
      target_origin_id           = "alb"
      path_pattern               = "/xi/api/v2/exchange_rates/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.medium_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    uk_api_exchange_rates = {
      target_origin_id           = "alb"
      path_pattern               = "/uk/api/v2/exchange_rates/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.medium_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    default_api_exchange_rates = {
      target_origin_id           = "alb"
      path_pattern               = "/api/v2/exchange_rates/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.medium_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # Search reference endpoints
    xi_api_search_references = {
      target_origin_id           = "alb"
      path_pattern               = "/xi/api/v2/search_references"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    uk_api_search_references = {
      target_origin_id           = "alb"
      path_pattern               = "/uk/api/v2/search_references"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    default_api_search_references = {
      target_origin_id           = "alb"
      path_pattern               = "/api/v2/search_references"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # News endpoints
    xi_api_news = {
      target_origin_id           = "alb"
      path_pattern               = "/xi/api/v2/news*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    uk_api_news = {
      target_origin_id           = "alb"
      path_pattern               = "/uk/api/v2/news*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    default_api_news = {
      target_origin_id           = "alb"
      path_pattern               = "/api/v2/news*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # API healthcheck endpoints
    xi_api_healthcheck = {
      target_origin_id           = "alb"
      path_pattern               = "/xi/api/v2/healthcheck"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    uk_api_healthcheck = {
      target_origin_id           = "alb"
      path_pattern               = "/uk/api/v2/healthcheck"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    default_api_healthcheck = {
      target_origin_id           = "alb"
      path_pattern               = "/api/v2/healthcheck"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # API v2 endpoints
    xi_api = {
      target_origin_id           = "alb"
      path_pattern               = "/xi/api/v2/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    uk_api = {
      target_origin_id           = "alb"
      path_pattern               = "/uk/api/v2/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    default_api = {
      target_origin_id           = "alb"
      path_pattern               = "/api/v2/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # API v1 endpoints TODO: this can be removed once we've migrated users to v2
    xi_v1_api = {
      target_origin_id           = "alb"
      path_pattern               = "/xi/api/v1/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    uk_v1_api = {
      target_origin_id           = "alb"
      path_pattern               = "/uk/api/v1/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
    default_v1_api = {
      target_origin_id           = "alb"
      path_pattern               = "/api/v1/*"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.long_cache.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }

    # Fallback for all other endpoints
    default = {
      target_origin_id           = "alb"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    }
  }

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

  cache_behavior = {
    default = {
      target_origin_id       = "api"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
  }

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

  cache_behavior = {
    default = {
      target_origin_id       = "reporting"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
  }

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

  cache_behavior = {
    default = {
      target_origin_id       = "dumps"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

      function_association = {
        "viewer-request" = {
          function_arn = aws_cloudfront_function.basic_auth.arn
        }
      }
    },
  }

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

  web_acl_id = module.waf.web_acl_id

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

  cache_behavior = {
    default = {
      target_origin_id       = "docs"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id
    },
  }

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.validated_certificate_arn
    depends_on = [
      module.acm.validated_certificate_arn
    ]
  }
}
