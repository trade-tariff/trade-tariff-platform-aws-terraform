mock_provider "aws" {}

variables {
  name  = "test-waf"
  scope = "REGIONAL"

  header_mismatch_label_rules = [
    { name = "label-non-mcp", priority = 2, header_name = "x-mcp-token", label = "non-mcp" }
  ]
  header_mismatch_label_values = {
    "label-non-mcp" = "test-token-value"
  }
}

# Sampled requests show every request header, and WAF cannot redact fields
# from them. Each WAF sees secret headers (Authorization, X-Waf-Bypass or
# X-Mcp-Token), so sampling is always off: for the web ACL (the default action)
# and for each rule.
run "sampled_requests_are_always_off" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl.this.visibility_config[0].sampled_requests_enabled == false
    error_message = "the web ACL must not sample requests"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].visibility_config[0].sampled_requests_enabled == false
    error_message = "standalone rules must not sample requests"
  }

  assert {
    condition     = alltrue([for rule in aws_wafv2_web_acl_rule.managed : rule.visibility_config[0].sampled_requests_enabled == false])
    error_message = "managed rule groups must not sample requests"
  }
}
