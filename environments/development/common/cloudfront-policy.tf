data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "random_password" "origin_header" {
  count   = 2
  length  = 16
  special = false
}

resource "aws_cloudfront_cache_policy" "very_very_long_cache" {
  name        = "very-very-long-cache"
  default_ttl = 31536000 # 1 year
  max_ttl     = 31536000 # 1 year
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config { cookie_behavior = "none" }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Accept",        # Routes to specific versions of our apis
          "Authorization", # Enables differentiated caching for authenticated users
          "X-Api-Key"      # Enables differentiated caching for authenticated users
        ]
      }
    }
    query_strings_config { query_string_behavior = "all" }
  }
}

resource "aws_cloudfront_cache_policy" "long_cache" {
  name        = "long-cache"
  default_ttl = 86400 # 1 day
  max_ttl     = 86400 # 1 day
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config { cookie_behavior = "none" }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Accept",        # Routes to specific versions of our apis
          "Authorization", # Enables differentiated caching for authenticated users
          "X-Api-Key"      # Enables differentiated caching for authenticated users
        ]
      }
    }
    query_strings_config { query_string_behavior = "all" }
  }
}

resource "aws_cloudfront_cache_policy" "medium_cache" {
  name        = "medium-cache"
  default_ttl = 7200 # 2 hours
  max_ttl     = 7200 # 2 hours
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config { cookie_behavior = "none" }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Accept",        # Routes to specific versions of our apis
          "Authorization", # Enables differentiated caching for authenticated users
          "X-Api-Key"      # Enables differentiated caching for authenticated users
        ]
      }
    }
    query_strings_config { query_string_behavior = "all" }
  }
}

resource "aws_cloudfront_cache_policy" "short_cache" {
  name        = "short-cache"
  default_ttl = 1800 # 30 minutes
  max_ttl     = 1800 # 30 minutes
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config { cookie_behavior = "none" }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Accept",        # Routes to specific versions of our apis
          "Authorization", # Enables differentiated caching for authenticated users
          "X-Api-Key"      # Enables differentiated caching for authenticated users
        ]
      }
    }
    query_strings_config { query_string_behavior = "all" }
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

resource "aws_cloudfront_response_headers_policy" "this" {
  name = "secure-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }

    xss_protection {
      mode_block = false
      override   = true
      protection = false
    }
  }

  cors_config {
    access_control_allow_origins {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD", "POST", "OPTIONS"]
    }

    access_control_max_age_sec = 7200

    access_control_allow_headers {
      items = ["Authorization"]
    }

    access_control_allow_credentials = true

    origin_override = false
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

resource "aws_s3_bucket_policy" "tech_docs" {
  bucket = aws_s3_bucket.this["tech-docs"].id
  policy = data.aws_iam_policy_document.tech_docs.json
}

data "aws_iam_policy_document" "tech_docs" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.this["tech-docs"].arn, "${aws_s3_bucket.this["tech-docs"].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.tech_docs_cdn.aws_cloudfront_distribution_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}
