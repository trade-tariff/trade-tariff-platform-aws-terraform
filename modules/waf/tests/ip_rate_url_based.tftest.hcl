run "ip_rate_url_based_created_with_expected_shape" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_rate_url_based_rules = [
      {
        name                  = "rate-limit-search"
        priority              = 6
        limit                 = 300
        action                = "block"
        search_string         = "/search"
        positional_constraint = "EXACTLY"
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-search"].priority == 6
    error_message = "ip_rate_url_based rule priority did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-search"].statement[0].rate_based_statement[0].limit == 300
    error_message = "rate limit value did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-search"].statement[0].rate_based_statement[0].scope_down_statement[0].byte_match_statement[0].search_string == "/search"
    error_message = "scope_down search_string did not match input"
  }
}

run "ip_rate_url_based_multiple_rules_get_distinct_priorities" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_rate_url_based_rules = [
      {
        name                  = "rate-limit-commodity-pages"
        priority              = 2
        limit                 = 1000
        action                = "block"
        search_string         = "/commodities/"
        positional_constraint = "STARTS_WITH"
      },
      {
        name                  = "rate-limit-search"
        priority              = 6
        limit                 = 300
        action                = "block"
        search_string         = "/search"
        positional_constraint = "EXACTLY"
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-commodity-pages"].priority != aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-search"].priority
    error_message = "distinct rules must not collapse onto the same priority"
  }
}

run "ip_rate_url_based_action_count_omits_block_config" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_rate_url_based_rules = [
      {
        name                  = "count-only-search"
        priority              = 6
        limit                 = 300
        action                = "count"
        search_string         = "/search"
        positional_constraint = "EXACTLY"
      }
    ]
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_rate_url_based["count-only-search"].action[0].count) == 1
    error_message = "action = count should produce a count block"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_rate_url_based["count-only-search"].action[0].block) == 0
    error_message = "action = count should not produce a block block"
  }
}

run "ip_rate_url_based_empty_list_creates_nothing" {
  command = plan

  variables {
    name                    = "test-waf"
    scope                   = "CLOUDFRONT"
    ip_rate_url_based_rules = []
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_rate_url_based) == 0
    error_message = "expected no ip_rate_url_based rules when list is empty"
  }
}
