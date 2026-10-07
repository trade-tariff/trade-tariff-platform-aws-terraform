mock_provider "aws" {}

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

run "ip_rate_url_based_regex_string_uses_regex_match" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_rate_url_based_rules = [
      {
        name         = "rate-limit-commodity-pages"
        priority     = 15
        limit        = 1000
        action       = "block"
        regex_string = "^/(uk/|xi/)?commodities/"
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-commodity-pages"].statement[0].rate_based_statement[0].scope_down_statement[0].regex_match_statement[0].regex_string == "^/(uk/|xi/)?commodities/"
    error_message = "regex_string should produce a regex_match_statement with the given pattern"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-commodity-pages"].statement[0].rate_based_statement[0].scope_down_statement[0].byte_match_statement) == 0
    error_message = "regex_string should not produce a byte_match_statement"
  }
}

run "ip_rate_url_based_search_string_omits_regex_match" {
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
    condition     = length(aws_wafv2_web_acl_rule.ip_rate_url_based["rate-limit-search"].statement[0].rate_based_statement[0].scope_down_statement[0].regex_match_statement) == 0
    error_message = "search_string should not produce a regex_match_statement"
  }
}

run "ip_rate_url_based_rejects_both_search_string_and_regex_string" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_rate_url_based_rules = [
      {
        name                  = "ambiguous"
        priority              = 6
        limit                 = 300
        action                = "block"
        search_string         = "/search"
        positional_constraint = "EXACTLY"
        regex_string          = "^/search$"
      }
    ]
  }

  expect_failures = [var.ip_rate_url_based_rules]
}

run "ip_rate_url_based_rejects_neither_search_string_nor_regex_string" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    ip_rate_url_based_rules = [
      {
        name     = "empty"
        priority = 6
        limit    = 300
        action   = "block"
      }
    ]
  }

  expect_failures = [var.ip_rate_url_based_rules]
}
