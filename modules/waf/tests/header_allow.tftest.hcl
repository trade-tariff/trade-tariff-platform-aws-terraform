run "header_allow_matches_values_by_name" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_allow_rules = [
      { name = "allow-mcp-server", priority = 0, header_name = "x-mcp-token" }
    ]
    header_allow_values = {
      "allow-mcp-server" = "test-token-value"
    }
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_allow["allow-mcp-server"].priority == 0
    error_message = "header_allow rule priority mismatch"
  }
}

run "header_allow_missing_value_fails_validation" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_allow_rules = [
      { name = "allow-mcp-server", priority = 0, header_name = "x-mcp-token" }
    ]
    header_allow_values = {} # deliberately missing the matching entry
  }

  expect_failures = [
    var.header_allow_values,
  ]
}