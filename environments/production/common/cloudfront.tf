module "cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.4.2"

  aliases = [
    var.domain_name,
    "signon.${var.domain_name}",
    "admin.${var.domain_name}",
    "www.${var.domain_name}",
    "hub.${var.domain_name}",
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
    frontend = {
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

  cache_behavior = {
    default = {
      target_origin_id       = "frontend"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = true

      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS",
        "PUT",
        "POST",
        "PATCH",
        "DELETE"
      ]

      cached_methods = [
        "GET",
        "HEAD"
      ]
    }

    green_lanes = {
      target_origin_id       = "frontend"
      viewer_protocol_policy = "redirect-to-https"

      path_pattern = "/xi/api/v2/green_lanes/*"

      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = true

      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS",
        "PUT",
        "POST",
        "PATCH",
        "DELETE"
      ]

      cached_methods = [
        "GET",
        "HEAD"
      ]
    }

    api = {
      target_origin_id       = "frontend"
      viewer_protocol_policy = "redirect-to-https"

      path_pattern = "/api/v2/*"

      cache_policy_id            = aws_cloudfront_cache_policy.cache_api.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.forward_all_qsa.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

      min_ttl     = 1
      default_ttl = 1800
      max_ttl     = 1800

      compress = true

      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS",
        "PUT",
        "POST",
        "PATCH",
        "DELETE"
      ]

      cached_methods = [
        "GET",
        "HEAD"
      ]
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
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.4.2"

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

      cache_policy_id            = aws_cloudfront_cache_policy.s3.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = true
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
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.4.2"

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

      cache_policy_id            = aws_cloudfront_cache_policy.s3.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.s3.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = true
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
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.4.2"

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

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = true

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
