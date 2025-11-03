resource "aws_cloudfront_distribution" "this" {
  count = var.create_distribution ? 1 : 0

  aliases             = var.aliases
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  web_acl_id          = var.web_acl_id
  tags                = var.tags

  dynamic "logging_config" {
    for_each = length(keys(var.logging_config)) == 0 ? [] : [var.logging_config]

    content {
      bucket          = logging_config.value["bucket"]
      prefix          = lookup(logging_config.value, "prefix", null)
      include_cookies = lookup(logging_config.value, "include_cookies", null)
    }
  }

  dynamic "origin" {
    for_each = var.origin

    content {
      domain_name              = origin.value.domain_name
      origin_id                = lookup(origin.value, "origin_id", origin.key)
      origin_path              = lookup(origin.value, "origin_path", null)
      origin_access_control_id = lookup(origin.value, "origin_access_control_id", null)

      dynamic "custom_origin_config" {
        for_each = length(lookup(origin.value, "custom_origin_config", "")) == 0 ? [] : [lookup(origin.value, "custom_origin_config", "")]
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", null)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_header", [])
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.origin_group

    content {
      origin_id = lookup(origin_group.value, "origin_id", origin_group.key)

      failover_criteria {
        status_codes = origin_group.value["failover_status_codes"]
      }

      member {
        origin_id = origin_group.value["primary_member_origin_id"]
      }

      member {
        origin_id = origin_group.value["secondary_member_origin_id"]
      }
    }
  }

  dynamic "default_cache_behavior" {
    for_each = [for behavior in var.cache_behaviors : behavior if behavior.path_pattern == null]

    content {
      target_origin_id       = default_cache_behavior.value.target_origin_id
      viewer_protocol_policy = default_cache_behavior.value.viewer_protocol_policy

      allowed_methods           = default_cache_behavior.value.allowed_methods
      cached_methods            = default_cache_behavior.value.cached_methods
      compress                  = default_cache_behavior.value.compress
      field_level_encryption_id = default_cache_behavior.value.field_level_encryption_id
      smooth_streaming          = default_cache_behavior.value.smooth_streaming
      trusted_signers           = default_cache_behavior.value.trusted_signers

      # NOTE: These are for legacy cache policies (where the cache policy is present this is vestigial).
      #
      # These defaults are what you get if you create a distribution without a legacy cache policy.
      min_ttl     = default_cache_behavior.value.min_ttl
      default_ttl = default_cache_behavior.value.default_ttl
      max_ttl     = default_cache_behavior.value.max_ttl

      cache_policy_id            = default_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = default_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = default_cache_behavior.value.response_headers_policy_id

      # Cloudfront Functions
      dynamic "function_association" {
        for_each = default_cache_behavior.value.function_association

        content {
          event_type   = function_association.key
          function_arn = function_association.value.function_arn
        }
      }

      # Lambda@Edge associations
      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value.lambda_function_association

        content {
          event_type   = lambda_function_association.key
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = [for behavior in var.cache_behaviors : behavior if behavior.path_pattern != null]

    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      allowed_methods = ordered_cache_behavior.value.allowed_methods
      cached_methods  = ordered_cache_behavior.value.cached_methods
      compress        = ordered_cache_behavior.value.compress

      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id
      smooth_streaming          = ordered_cache_behavior.value.smooth_streaming
      trusted_signers           = ordered_cache_behavior.value.trusted_signers

      # NOTE: These are for legacy cache policies (where the cache policy is present this is vestigial).
      min_ttl     = ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl

      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_association

        content {
          event_type   = function_association.key
          function_arn = function_association.value.function_arn
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association

        content {
          event_type   = lambda_function_association.key
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = lookup(var.viewer_certificate, "acm_certificate_arn", null)
    cloudfront_default_certificate = lookup(var.viewer_certificate, "cloudfront_default_certificate", null)
    iam_certificate_id             = lookup(var.viewer_certificate, "iam_certificate_id", null)

    minimum_protocol_version = lookup(var.viewer_certificate, "minimum_protocol_version", "TLSv1.2_2021")
    ssl_support_method       = lookup(var.viewer_certificate, "ssl_support_method", null)
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_code = custom_error_response.value["error_code"]

      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.geo_restriction]

      content {
        restriction_type = lookup(geo_restriction.value, "restriction_type", "none")
        locations        = lookup(geo_restriction.value, "locations", [])
      }
    }
  }
}

resource "aws_route53_record" "alias_record" {
  for_each = {
    for alias in var.aliases : alias => alias
    if var.create_alias
  }
  name    = each.key
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cname_record" {
  for_each = {
    for alias in var.aliases : alias => alias
    if var.create_cname
  }
  name            = each.key
  type            = "CNAME"
  ttl             = 60
  records         = [aws_cloudfront_distribution.this[0].domain_name]
  zone_id         = var.route53_zone_id
  health_check_id = var.health_check_id
}
