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

run "creates_distribution_by_default" {
  command = plan

  assert {
    condition     = length(aws_cloudfront_distribution.this) == 1
    error_message = "One distribution must be created when create_distribution is true."
  }
}

run "has_no_logging_config_when_none_is_given" {
  command = plan

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].logging_config) == 0
    error_message = "There must be no logging_config block when logging_config is empty."
  }
}

run "writes_access_logs_when_logging_config_is_given" {
  command = plan

  variables {
    logging_config = {
      bucket = "tariff-logs.s3.amazonaws.com"
      prefix = "cloudfront/staging"
    }
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].logging_config) == 1
    error_message = "There must be one logging_config block when logging_config is given."
  }

  assert {
    condition     = aws_cloudfront_distribution.this[0].logging_config[0].bucket == "tariff-logs.s3.amazonaws.com"
    error_message = "Access logs must go to the bucket that the caller gives."
  }

  assert {
    condition     = aws_cloudfront_distribution.this[0].logging_config[0].prefix == "cloudfront/staging"
    error_message = "Access logs must use the prefix that the caller gives."
  }
}

run "has_no_custom_error_responses_by_default" {
  command = plan

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].custom_error_response) == 0
    error_message = "There must be no custom_error_response blocks when custom_error_response is null."
  }
}

run "creates_one_custom_error_response_per_item" {
  command = plan

  variables {
    custom_error_response = [
      { error_code = 404, response_code = 404, response_page_path = "/404.html" },
      { error_code = 503, response_code = 503, response_page_path = "/503.html", error_caching_min_ttl = 10 },
    ]
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].custom_error_response) == 2
    error_message = "There must be one custom_error_response block for each item that the caller gives."
  }

  assert {
    condition = one([
      for response in aws_cloudfront_distribution.this[0].custom_error_response : response
      if response.error_code == 503
    ]).response_page_path == "/503.html"
    error_message = "Each custom_error_response must keep the response_page_path that the caller gives."
  }
}
