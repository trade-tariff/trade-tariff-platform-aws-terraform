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

run "has_no_geo_restriction_by_default" {
  command = plan

  assert {
    condition     = one(one(aws_cloudfront_distribution.this[0].restrictions).geo_restriction).restriction_type == "none"
    error_message = "The distribution must have no geo restriction by default."
  }
}

run "accepts_whitelist_with_two_character_country_codes" {
  command = plan

  variables {
    geo_restriction = {
      restriction_type = "whitelist"
      locations        = ["GB", "IE"]
    }
  }

  assert {
    condition     = one(one(aws_cloudfront_distribution.this[0].restrictions).geo_restriction).restriction_type == "whitelist"
    error_message = "The restriction_type that the caller gives must be used."
  }

  assert {
    condition     = one(one(aws_cloudfront_distribution.this[0].restrictions).geo_restriction).locations == toset(["GB", "IE"])
    error_message = "The locations that the caller gives must be used."
  }
}

run "rejects_unknown_restriction_type" {
  command = plan

  variables {
    geo_restriction = {
      restriction_type = "allowlist"
      locations        = ["GB"]
    }
  }

  expect_failures = [
    var.geo_restriction,
  ]
}

run "rejects_location_that_is_not_two_characters" {
  command = plan

  variables {
    geo_restriction = {
      restriction_type = "blacklist"
      locations        = ["GBR"]
    }
  }

  expect_failures = [
    var.geo_restriction,
  ]
}
