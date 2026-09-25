mock_provider "aws" {}

variables {
  name  = "test-waf"
  scope = "REGIONAL"

  header_mismatch_label_rules = [
    { name = "label-non-mcp", priority = 2, header_name = "X-Mcp-Token", label = "non-mcp" }
  ]
  header_mismatch_label_values = {
    "label-non-mcp" = "test-token-value"
  }
}

run "labels_requests_whose_header_does_not_exactly_match_the_secret" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].statement[0].not_statement[0].statement[0].byte_match_statement[0].positional_constraint == "EXACTLY"
    error_message = "the header must be compared with an exact match inside a not_statement"
  }

  # WAF matches single_header names against the lowercased header, so the
  # module must lowercase whatever casing is configured.
  assert {
    condition     = aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_header[0].name == "x-mcp-token"
    error_message = "header name must be lowercased for the single_header field match"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].rule_label[0].name == "non-mcp"
    error_message = "the rule must attach the configured label"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].priority == 2
    error_message = "the rule must use the configured priority"
  }
}

run "action_is_always_non_terminating_count" {
  command = plan

  # A terminating allow here would skip every later rule, including the
  # managed rule groups, for anyone who sends the header.
  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].action[0].count) == 1
    error_message = "the rule must use a non-terminating count action"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].action[0].allow) == 0
    error_message = "the rule must never use a terminating allow action"
  }
}

run "missing_value_fails_validation" {
  command = plan

  variables {
    header_mismatch_label_values = {} # deliberately missing the matching entry
  }

  expect_failures = [
    var.header_mismatch_label_values,
  ]
}
