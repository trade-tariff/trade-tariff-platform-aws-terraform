mock_provider "aws" {}

variables {
  aliases = ["example.trade-tariff.service.gov.uk"]

  origin = {
    alb = {
      domain_name = "alb.example.com"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_read_timeout    = 120
      }
      custom_header = [
        { name = "x-origin-secret-name", value = "x-origin-secret-value" },
      ]
    }

    assets = {
      domain_name              = "assets-bucket.s3.eu-west-2.amazonaws.com"
      origin_id                = "s3-assets"
      origin_path              = "/public"
      origin_access_control_id = "E2QWRUHAPOMQZL"
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

run "creates_one_origin_per_map_entry" {
  command = plan

  assert {
    condition     = toset([for origin in aws_cloudfront_distribution.this[0].origin : origin.origin_id]) == toset(["alb", "s3-assets"])
    error_message = "There must be one origin for each entry in var.origin."
  }
}

run "uses_map_key_as_origin_id_when_none_is_given" {
  command = plan

  assert {
    condition     = one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "alb"]).domain_name == "alb.example.com"
    error_message = "An origin without origin_id must use its map key as origin_id."
  }
}

run "uses_explicit_origin_id_and_s3_settings" {
  command = plan

  assert {
    condition     = one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "s3-assets"]).origin_path == "/public"
    error_message = "An origin must keep the origin_path that the caller gives."
  }

  assert {
    condition     = one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "s3-assets"]).origin_access_control_id == "E2QWRUHAPOMQZL"
    error_message = "An origin must keep the origin_access_control_id that the caller gives."
  }

  assert {
    condition     = length(one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "s3-assets"]).custom_origin_config) == 0
    error_message = "An origin without custom_origin_config must have no custom_origin_config block."
  }
}

run "sets_custom_origin_config_when_given" {
  command = plan

  assert {
    condition     = length(one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "alb"]).custom_origin_config) == 1
    error_message = "An origin with custom_origin_config must have one custom_origin_config block."
  }

  assert {
    condition     = one(one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "alb"]).custom_origin_config).origin_protocol_policy == "https-only"
    error_message = "The origin must keep the origin_protocol_policy that the caller gives."
  }

  assert {
    condition     = one(one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "alb"]).custom_origin_config).origin_ssl_protocols == toset(["TLSv1.2"])
    error_message = "The origin must keep the origin_ssl_protocols that the caller gives."
  }

  assert {
    condition     = one(one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "alb"]).custom_origin_config).origin_read_timeout == 120
    error_message = "The origin must keep the optional origin_read_timeout that the caller gives."
  }
}

run "sends_custom_headers_to_the_origin" {
  command = plan

  assert {
    condition = one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "alb"]).custom_header == toset([
      { name = "x-origin-secret-name", value = "x-origin-secret-value" },
    ])
    error_message = "The origin must send each custom_header that the caller gives."
  }

  assert {
    condition     = length(one([for origin in aws_cloudfront_distribution.this[0].origin : origin if origin.origin_id == "s3-assets"]).custom_header) == 0
    error_message = "An origin without custom_header must send no custom headers."
  }
}

run "has_no_origin_groups_by_default" {
  command = plan

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].origin_group) == 0
    error_message = "There must be no origin_group blocks when origin_group is empty."
  }
}

run "builds_failover_origin_group_from_primary_and_secondary" {
  command = plan

  variables {
    origin_group = {
      failover = {
        failover_status_codes      = [500, 502, 503, 504]
        primary_member_origin_id   = "alb"
        secondary_member_origin_id = "s3-assets"
      }
    }
  }

  assert {
    condition     = one(aws_cloudfront_distribution.this[0].origin_group).origin_id == "failover"
    error_message = "An origin_group without origin_id must use its map key as origin_id."
  }

  assert {
    condition     = one(one(aws_cloudfront_distribution.this[0].origin_group).failover_criteria).status_codes == toset([500, 502, 503, 504])
    error_message = "The origin_group must fail over on the status codes that the caller gives."
  }

  # member is an ordered list: the first member is the primary origin.
  assert {
    condition     = [for member in one(aws_cloudfront_distribution.this[0].origin_group).member : member.origin_id] == ["alb", "s3-assets"]
    error_message = "The origin_group members must be the primary origin first, then the secondary origin."
  }
}
