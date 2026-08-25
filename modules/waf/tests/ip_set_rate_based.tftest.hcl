mock_provider "aws" {}

run "ip_set_rate_based_created_with_expected_shape" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_set_rate_based_rules = [
      {
        name       = "tss-scraper-rate-limit"
        priority   = 1
        limit      = 500
        action     = "block"
        ip_set_arn = "arn:aws:wafv2:us-east-1:123456789012:global/ipset/tss-scraper/abc123"
        custom_response = {
          response_code = 429
          body_key      = "rate-limit-exceeded"
          response_header = {
            name  = "X-Rate-Limit"
            value = "1"
          }
        }
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_set_rate_based["tss-scraper-rate-limit"].priority == 1
    error_message = "ip_set_rate_based rule priority did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_set_rate_based["tss-scraper-rate-limit"].statement[0].rate_based_statement[0].limit == 500
    error_message = "rate limit value did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_set_rate_based["tss-scraper-rate-limit"].statement[0].rate_based_statement[0].scope_down_statement[0].ip_set_reference_statement[0].arn == "arn:aws:wafv2:us-east-1:123456789012:global/ipset/tss-scraper/abc123"
    error_message = "scope_down ip_set_arn did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_set_rate_based["tss-scraper-rate-limit"].action[0].block[0].custom_response[0].response_code == 429
    error_message = "custom_response.response_code did not match input"
  }
}

run "ip_set_rate_based_action_count_omits_block_config" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_set_rate_based_rules = [
      {
        name       = "count-only-ip-set"
        priority   = 1
        limit      = 500
        action     = "count"
        ip_set_arn = "arn:aws:wafv2:us-east-1:123456789012:global/ipset/tss-scraper/abc123"
        custom_response = {
          response_code = 429
          body_key      = "rate-limit-exceeded"
          response_header = {
            name  = "X-Rate-Limit"
            value = "1"
          }
        }
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_set_rate_based["count-only-ip-set"].action[0].count) == 1
    error_message = "action = count should produce a count block"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_set_rate_based["count-only-ip-set"].action[0].block) == 0
    error_message = "action = count should not produce a block block"
  }
}

run "ip_set_rate_based_empty_list_creates_nothing" {
  command = plan

  variables {
    name                    = "test-waf"
    scope                   = "CLOUDFRONT"
    ip_set_rate_based_rules = []
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_set_rate_based) == 0
    error_message = "expected no ip_set_rate_based rules when list is empty"
  }
}
