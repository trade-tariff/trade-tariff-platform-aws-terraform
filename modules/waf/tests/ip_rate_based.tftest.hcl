mock_provider "aws" {}

run "allow_assets_from_rate_limit_created_at_priority_0" {
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

        response_header = {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
    }
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.allow_assets_from_rate_limit["allow-assets-from-rate-limit"].priority == 0
    error_message = "allow-assets rule priority should be ip_rate_based_rule.priority - 1 (1 - 1 = 0)"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.allow_assets_from_rate_limit["allow-assets-from-rate-limit"].action[0].allow) == 1
    error_message = "allow-assets rule action must be allow"
  }

  assert {
    condition = aws_wafv2_web_acl_rule.allow_assets_from_rate_limit["allow-assets-from-rate-limit"].statement[0].regex_pattern_set_reference_statement[0].arn == aws_wafv2_regex_pattern_set.this.arn

    error_message = "allow-assets rule must reference the shared asset regex pattern set"
  }
}
