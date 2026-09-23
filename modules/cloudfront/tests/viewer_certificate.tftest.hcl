mock_provider "aws" {}

variables {
  aliases = ["example.trade-tariff.service.gov.uk"]

  origin = {
    alb = {
      domain_name = "alb.example.com"
    }
  }

  cache_behaviors = [
    {
      name                       = "default"
      target_origin_id           = "alb"
      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    },
  ]
}

run "uses_tls_1_2_2021_when_acm_certificate_has_no_minimum_version" {
  command = plan

  variables {
    viewer_certificate = {
      acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
      ssl_support_method  = "sni-only"
    }
  }

  assert {
    condition     = one(aws_cloudfront_distribution.this[0].viewer_certificate).minimum_protocol_version == "TLSv1.2_2021"
    error_message = "minimum_protocol_version must fall back to TLSv1.2_2021 when the caller does not set it."
  }

  assert {
    condition     = one(aws_cloudfront_distribution.this[0].viewer_certificate).acm_certificate_arn == "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
    error_message = "The ACM certificate that the caller gives must be used."
  }

  assert {
    condition     = one(aws_cloudfront_distribution.this[0].viewer_certificate).cloudfront_default_certificate == null
    error_message = "The CloudFront default certificate must not be used when an ACM certificate is given."
  }
}

run "uses_minimum_version_that_caller_gives" {
  command = plan

  variables {
    viewer_certificate = {
      acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2025"
    }
  }

  assert {
    condition     = one(aws_cloudfront_distribution.this[0].viewer_certificate).minimum_protocol_version == "TLSv1.2_2025"
    error_message = "minimum_protocol_version must be the value that the caller gives."
  }
}

run "uses_cloudfront_default_certificate_when_no_certificate_is_given" {
  command = plan

  # The variable default sets minimum_protocol_version to TLSv1, so the
  # TLSv1.2_2021 fallback in main.tf does not apply here. This run does not
  # assert the TLS version, so that it does not lock in that weak default.
  assert {
    condition     = one(aws_cloudfront_distribution.this[0].viewer_certificate).cloudfront_default_certificate == true
    error_message = "The CloudFront default certificate must be used when the caller gives no viewer_certificate."
  }
}
