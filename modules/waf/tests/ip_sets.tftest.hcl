run "ip_sets_rule_created_with_expected_shape" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "REGIONAL"

    ip_sets_rule = [
      {
        name       = "block-known-bad-ips"
        priority   = 10
        action     = "block"
        ip_set_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/00000000-0000-0000-0000-000000000000"
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_sets["block-known-bad-ips"].priority == 10
    error_message = "ip_sets rule priority did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ip_sets["block-known-bad-ips"].name == "block-known-bad-ips"
    error_message = "ip_sets rule name did not match input"
  }
}

run "ip_sets_rule_empty_list_creates_nothing" {
  command = plan

  variables {
    name          = "test-waf"
    scope         = "REGIONAL"
    ip_sets_rule  = []
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ip_sets) == 0
    error_message = "expected no ip_sets rules when list is empty"
  }
}