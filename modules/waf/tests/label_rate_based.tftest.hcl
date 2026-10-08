mock_provider "aws" {}

variables {
  name  = "test-waf"
  scope = "CLOUDFRONT"

  header_regex_label_rules = [
    {
      name         = "label-no-api-key"
      priority     = 11
      header_name  = "X-Api-Key"
      regex_string = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
      label        = "no-api-key"
      negate       = true
    }
  ]

  label_rate_based_rules = [
    {
      name     = "ratelimiting-no-api-key"
      priority = 12
      limit    = 100
      action   = "count"
      label    = "no-api-key"
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

run "labelling_rule_negates_and_lowercases_the_header" {
  command = plan

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_regex_label["label-no-api-key"].statement[0].not_statement) == 1
    error_message = "negate = true must wrap the regex match in a not_statement"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_regex_label["label-no-api-key"].statement[0].regex_match_statement) == 0
    error_message = "negate = true must not also emit a bare regex_match_statement"
  }

  # WAF matches single_header names case-sensitively against the lowercased
  # header, so the module must lowercase whatever casing is configured.
  assert {
    condition     = aws_wafv2_web_acl_rule.header_regex_label["label-no-api-key"].statement[0].not_statement[0].statement[0].regex_match_statement[0].field_to_match[0].single_header[0].name == "x-api-key"
    error_message = "header name must be lowercased for the single_header field match"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_regex_label["label-no-api-key"].rule_label[0].name == "no-api-key"
    error_message = "labelling rule must attach the configured label"
  }
}

run "labelling_rule_action_is_always_non_terminating_count" {
  command = plan

  # A terminating allow here would skip every later rule - including the
  # managed SQLi and bot control groups - for anyone sending the header.
  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_regex_label["label-no-api-key"].action[0].count) == 1
    error_message = "labelling rule must use a non-terminating count action"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_regex_label["label-no-api-key"].action[0].allow) == 0
    error_message = "labelling rule must never use a terminating allow action"
  }
}

run "labelling_rule_must_be_evaluated_before_the_rule_that_matches_its_label" {
  command = plan

  # A label match only sees labels added earlier in the Web ACL evaluation,
  # so the labelling rule needs the lower priority number of the pair.
  assert {
    condition     = aws_wafv2_web_acl_rule.header_regex_label["label-no-api-key"].priority < aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-api-key"].priority
    error_message = "labelling rule priority must be lower than the label rate-based rule that consumes it"
  }
}

run "label_rate_based_scopes_the_rate_limit_to_the_label" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-api-key"].statement[0].rate_based_statement[0].limit == 100
    error_message = "rate limit value did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-api-key"].statement[0].rate_based_statement[0].scope_down_statement[0].label_match_statement[0].key == "no-api-key"
    error_message = "scope_down must match the label emitted by the labelling rule"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-api-key"].statement[0].rate_based_statement[0].scope_down_statement[0].label_match_statement[0].scope == "LABEL"
    error_message = "label match scope must be LABEL, not NAMESPACE"
  }
}

run "non_negated_labelling_rule_emits_a_bare_regex_match" {
  command = plan

  variables {
    header_regex_label_rules = [
      {
        name         = "label-has-api-key"
        priority     = 11
        header_name  = "x-api-key"
        regex_string = "^[0-9a-fA-F]{8}-.*$"
        label        = "has-api-key"
        negate       = false
      }
    ]
    label_rate_based_rules = []
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_regex_label["label-has-api-key"].statement[0].regex_match_statement) == 1
    error_message = "negate = false must emit a bare regex_match_statement"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_regex_label["label-has-api-key"].statement[0].not_statement) == 0
    error_message = "negate = false must not wrap the match in a not_statement"
  }
}

run "empty_lists_create_nothing" {
  command = plan

  variables {
    header_regex_label_rules = []
    label_rate_based_rules   = []
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_regex_label) == 0 && length(aws_wafv2_web_acl_rule.label_rate_based) == 0
    error_message = "expected no rules when both lists are empty"
  }
}

run "reserved_label_names_are_rejected" {
  command = plan

  variables {
    header_regex_label_rules = [
      {
        name         = "label-reserved"
        priority     = 11
        header_name  = "x-api-key"
        regex_string = "^.*$"
        label        = "awswaf"
        negate       = true
      }
    ]
    label_rate_based_rules = []
  }

  expect_failures = [var.header_regex_label_rules]
}

run "rate_based_aggregates_by_ip_by_default" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-api-key"].statement[0].rate_based_statement[0].aggregate_key_type == "IP"
    error_message = "label_rate_based rules must aggregate by IP when aggregate_key is not set"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-api-key"].statement[0].rate_based_statement[0].custom_keys) == 0
    error_message = "IP aggregation must not add custom keys"
  }
}

run "rate_based_aggregates_by_ja4_when_requested" {
  command = plan

  variables {
    label_rate_based_rules = [
      {
        name          = "ratelimiting-no-alpn-pages"
        priority      = 14
        limit         = 300
        action        = "count"
        label         = "no-alpn-page"
        aggregate_key = "JA4"
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
    condition     = aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-alpn-pages"].statement[0].rate_based_statement[0].aggregate_key_type == "CUSTOM_KEYS"
    error_message = "aggregate_key = JA4 must use CUSTOM_KEYS aggregation"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.label_rate_based["ratelimiting-no-alpn-pages"].statement[0].rate_based_statement[0].custom_keys[0].ja4_fingerprint[0].fallback_behavior == "NO_MATCH"
    error_message = "aggregate_key = JA4 must use the JA4 fingerprint as the only custom key"
  }
}

run "rate_based_rejects_unknown_aggregate_key" {
  command = plan

  variables {
    label_rate_based_rules = [
      {
        name          = "ratelimiting-unknown"
        priority      = 14
        limit         = 300
        action        = "count"
        label         = "no-alpn-page"
        aggregate_key = "JA3"
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

  expect_failures = [var.label_rate_based_rules]
}
