# Rate-limit 429s must carry Retry-After so that clients have something
# actionable to back off against. The WAF rate-based rules use a fixed 60
# second evaluation window, so 60 is the honest value to advertise.
#
# AWS WAF permits up to 10 custom response headers per response, so each
# rate-limited rule takes a map of headers rather than a single pair.
mock_provider "aws" {}

run "ip_rate_based_rule_emits_every_custom_response_header" {
  command = apply

  override_resource {
    target = aws_wafv2_regex_pattern_set.this

    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:global/regexpatternset/test-waf/12345678-abcd-1234-abcd-123456789012"
    }
  }

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_rate_based_rule = {
      name      = "ratelimiting"
      priority  = 1
      rpm_limit = 500
      action    = "block"

      custom_response = {
        response_code = 429
        body_key      = "rate-limit-exceeded"

        response_headers = {
          "Retry-After"      = "60"
          "RateLimit-Policy" = "500;w=60"
        }
      }
    }
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_rate_based["ratelimiting"].action[0].block[0].custom_response[0].response_header) == 2
    error_message = "every header in custom_response.response_headers must reach the rule"
  }

  assert {
    condition = length([
      for header in aws_wafv2_web_acl_rule.ip_rate_based["ratelimiting"].action[0].block[0].custom_response[0].response_header :
      header if header.name == "Retry-After" && header.value == "60"
    ]) == 1
    error_message = "a rate-limit 429 must carry Retry-After matching the 60 second evaluation window"
  }
}

run "label_rate_based_rule_emits_every_custom_response_header" {
  command = apply

  override_resource {
    target = aws_wafv2_regex_pattern_set.this

    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:global/regexpatternset/test-waf/12345678-abcd-1234-abcd-123456789012"
    }
  }

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    label_rate_based_rules = [
      {
        name     = "ratelimiting-no-api-key"
        priority = 12
        limit    = 250
        action   = "block"
        label    = "no-api-key"

        custom_response = {
          response_code = 429
          body_key      = "rate-limit-exceeded"

          response_headers = {
            "Retry-After"      = "60"
            "RateLimit-Policy" = "250;w=60"
          }
        }
      }
    ]
  }

  assert {
    condition = length([
      for header in aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-api-key"].action[0].block[0].custom_response[0].response_header :
      header if header.name == "Retry-After" && header.value == "60"
    ]) == 1
    error_message = "a label rate-limit 429 must carry Retry-After"
  }
}

run "ip_set_rate_based_rule_emits_every_custom_response_header" {
  command = apply

  override_resource {
    target = aws_wafv2_regex_pattern_set.this

    values = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:global/regexpatternset/test-waf/12345678-abcd-1234-abcd-123456789012"
    }
  }

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_set_rate_based_rules = [
      {
        name       = "tss-scraper-rate-limit"
        priority   = 1
        limit      = 500
        action     = "block"
        ip_set_arn = "arn:aws:wafv2:us-east-1:123456789012:global/ipset/tss/12345678-abcd-1234-abcd-123456789012"

        custom_response = {
          response_code = 429
          body_key      = "rate-limit-exceeded"

          response_headers = {
            "Retry-After"      = "60"
            "RateLimit-Policy" = "500;w=60"
          }
        }
      }
    ]
  }

  assert {
    condition = length([
      for header in aws_wafv2_web_acl_rule.ip_set_rate_based["tss-scraper-rate-limit"].action[0].block[0].custom_response[0].response_header :
      header if header.name == "Retry-After" && header.value == "60"
    ]) == 1
    error_message = "an ip-set rate-limit 429 must carry Retry-After"
  }
}
