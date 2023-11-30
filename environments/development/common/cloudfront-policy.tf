data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_cache_policy" "cache_api" {
  name        = "cache-apiv2"
  default_ttl = 180
  max_ttl     = 180
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "if-modified-since",
          "if-none-match",
        ]
      }
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
