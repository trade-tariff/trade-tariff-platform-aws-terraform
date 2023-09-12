data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

module "cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.2.1"

  aliases         = [var.domain_name, "signon.${var.domain_name}", "admin.${var.domain_name}"]
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
    }
  }

  cache_behavior = {
    default = {
      target_origin_id       = "frontend"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.forward_all_qsa.id

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = false

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

resource "aws_cloudfront_cache_policy" "cache_all_qsa" {
  name        = "Cache-All-QSA-${var.environment}"
  comment     = "Cache all QSA (managed by Terraform)"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "forward_all_qsa" {
  name    = "Forward-All-QSA-${var.environment}"
  comment = "Forward all QSA (managed by Terraform)"
  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "allViewer"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

# API Docs Cloudfront
module "api_cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.2.1"

  aliases         = ["api.${var.domain_name}"]
  create_alias    = true
  route53_zone_id = data.aws_route53_zone.this.id
  comment         = "API Docs ${title(var.environment)} CDN"

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
      domain_name = aws_s3_bucket.this["api-docs"].bucket_regional_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  cache_behavior = {
    default = {
      target_origin_id       = "api"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.forward_all_qsa.id

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = false

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
