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
      name                       = "uk_api"
      path_pattern               = "/uk/api/*"
      target_origin_id           = "alb"
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
      lambda_function_association = {
        "viewer-request" = {
          lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:viewer-request-auth:3"
        }
      }
    },
    {
      name                       = "xi_api"
      path_pattern               = "/xi/api/*"
      target_origin_id           = "alb"
      viewer_protocol_policy     = "https-only"
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    },
    {
      name                       = "default"
      target_origin_id           = "alb"
      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
      function_association = {
        "viewer-request" = {
          function_arn = "arn:aws:cloudfront::123456789012:function/redirect"
        }
      }
    },
  ]
}

run "uses_behavior_without_path_pattern_as_default" {
  command = plan

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].default_cache_behavior) == 1
    error_message = "There must be exactly one default_cache_behavior."
  }

  assert {
    condition     = aws_cloudfront_distribution.this[0].default_cache_behavior[0].cache_policy_id == "658327ea-f89d-4fab-a63d-7e88639e58f6"
    error_message = "The behavior without path_pattern must become the default_cache_behavior."
  }
}

run "keeps_path_behaviors_in_caller_order" {
  command = plan

  assert {
    condition     = [for behavior in aws_cloudfront_distribution.this[0].ordered_cache_behavior : behavior.path_pattern] == ["/uk/api/*", "/xi/api/*"]
    error_message = "Behaviors with a path_pattern must become ordered_cache_behavior blocks in the order that the caller gives."
  }
}

run "redirects_viewers_to_https_by_default" {
  command = plan

  assert {
    condition     = aws_cloudfront_distribution.this[0].default_cache_behavior[0].viewer_protocol_policy == "redirect-to-https"
    error_message = "The default behavior must redirect viewers to HTTPS when viewer_protocol_policy is not given."
  }

  assert {
    condition     = aws_cloudfront_distribution.this[0].ordered_cache_behavior[0].viewer_protocol_policy == "redirect-to-https"
    error_message = "An ordered behavior must redirect viewers to HTTPS when viewer_protocol_policy is not given."
  }

  assert {
    condition     = aws_cloudfront_distribution.this[0].ordered_cache_behavior[1].viewer_protocol_policy == "https-only"
    error_message = "An ordered behavior must keep the viewer_protocol_policy that the caller gives."
  }
}

run "applies_optional_defaults_to_every_behavior" {
  command = plan

  assert {
    condition     = aws_cloudfront_distribution.this[0].default_cache_behavior[0].compress == true
    error_message = "The default behavior must compress responses by default."
  }

  assert {
    condition     = aws_cloudfront_distribution.this[0].default_cache_behavior[0].cached_methods == toset(["GET", "HEAD"])
    error_message = "The default behavior must cache only GET and HEAD by default."
  }

  assert {
    condition     = alltrue([for behavior in aws_cloudfront_distribution.this[0].ordered_cache_behavior : behavior.compress == true])
    error_message = "Every ordered behavior must compress responses by default."
  }
}

run "attaches_cloudfront_functions_by_event_type" {
  command = plan

  assert {
    condition = aws_cloudfront_distribution.this[0].default_cache_behavior[0].function_association == toset([
      { event_type = "viewer-request", function_arn = "arn:aws:cloudfront::123456789012:function/redirect" },
    ])
    error_message = "Each function_association map key must become the event_type of a function association."
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].ordered_cache_behavior[0].function_association) == 0
    error_message = "A behavior without function_association must have no function associations."
  }
}

run "attaches_lambda_at_edge_by_event_type" {
  command = plan

  assert {
    condition     = one(aws_cloudfront_distribution.this[0].ordered_cache_behavior[0].lambda_function_association).event_type == "viewer-request"
    error_message = "Each lambda_function_association map key must become the event_type of a Lambda@Edge association."
  }

  assert {
    condition     = one(aws_cloudfront_distribution.this[0].ordered_cache_behavior[0].lambda_function_association).lambda_arn == "arn:aws:lambda:us-east-1:123456789012:function:viewer-request-auth:3"
    error_message = "Each Lambda@Edge association must use the lambda_arn that the caller gives."
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this[0].default_cache_behavior[0].lambda_function_association) == 0
    error_message = "A behavior without lambda_function_association must have no Lambda@Edge associations."
  }
}
