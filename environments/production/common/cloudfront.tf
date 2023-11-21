data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

module "cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.3.0"

  aliases         = [var.domain_name, "signon.${var.domain_name}", "admin.${var.domain_name}", "www.${var.domain_name}"]
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
      domain_name = module.alb.dns_name
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

resource "aws_cloudfront_origin_request_policy" "s3" {
  name    = "CORS-S3Origin-${var.environment}"
  comment = "Custom version of Managed-CORS-S3Origin (managed by Terraform)"
  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_cache_policy" "s3" {
  name = "s3"

  comment = "Enables caching s3 buckets. Bucket policies restrict specific cloudfront distributions."

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

resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "s3"
  description                       = "Enables accessing s3 buckets. Bucket policies restrict specific cloudfront distributions."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "api" {
  bucket = aws_s3_bucket.this["api-docs"].id
  policy = data.aws_iam_policy_document.api.json
}

data "aws_iam_policy_document" "api" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.this["api-docs"].arn, "${aws_s3_bucket.this["api-docs"].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.api_cdn.aws_cloudfront_distribution_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

module "api_cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.3.0"

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

      cache_policy_id          = aws_cloudfront_cache_policy.s3.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.s3.id

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

resource "aws_s3_bucket_policy" "reporting" {
  bucket = aws_s3_bucket.this["reporting"].id
  policy = data.aws_iam_policy_document.reporting.json
}

data "aws_iam_policy_document" "reporting" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.this["reporting"].arn, "${aws_s3_bucket.this["reporting"].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.reporting_cdn.aws_cloudfront_distribution_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

module "reporting_cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.3.0"

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

      cache_policy_id          = aws_cloudfront_cache_policy.s3.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.s3.id

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

resource "aws_s3_bucket_policy" "backups" {
  bucket = aws_s3_bucket.this["database-backups"].id
  policy = data.aws_iam_policy_document.backups.json
}

data "aws_iam_policy_document" "backups" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.this["database-backups"].arn, "${aws_s3_bucket.this["database-backups"].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.backups_cdn.aws_cloudfront_distribution_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

module "backups_cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.4.1"

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

      cache_policy_id          = aws_cloudfront_cache_policy.s3.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.s3.id

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
