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

run "sampled_requests_are_on_by_default" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl.this.visibility_config[0].sampled_requests_enabled == true
    error_message = "the web ACL must keep sampled requests on by default"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].visibility_config[0].sampled_requests_enabled == true
    error_message = "rules must keep sampled requests on by default"
  }
}

# Sampled requests show every request header, and WAF cannot redact fields
# from them. A WAF that sees secret headers must be able to turn sampling off
# for the web ACL (the default action) and for each rule.
run "sampled_requests_can_be_turned_off" {
  command = plan

  variables {
    sampled_requests_enabled = false
  }

  assert {
    condition     = aws_wafv2_web_acl.this.visibility_config[0].sampled_requests_enabled == false
    error_message = "the web ACL must not sample requests when sampling is off"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_mismatch_label["label-non-mcp"].visibility_config[0].sampled_requests_enabled == false
    error_message = "standalone rules must not sample requests when sampling is off"
  }

  assert {
    condition     = alltrue([for rule in aws_wafv2_web_acl_rule.managed : rule.visibility_config[0].sampled_requests_enabled == false])
    error_message = "managed rule groups must not sample requests when sampling is off"
  }
}
