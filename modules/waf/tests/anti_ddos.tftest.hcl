mock_provider "aws" {}

variables {
  name  = "test-waf"
  scope = "CLOUDFRONT"

  anti_ddos_rule = {
    priority             = 5
    override_action      = "count"
    sensitivity_to_block = "LOW"
  }
}

run "anti_ddos_rule_references_managed_group" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.anti_ddos["AWSManagedRulesAntiDDoSRuleSet"].priority == 5
    error_message = "anti_ddos priority did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.anti_ddos["AWSManagedRulesAntiDDoSRuleSet"].statement[0].managed_rule_group_statement[0].name == "AWSManagedRulesAntiDDoSRuleSet"
    error_message = "anti_ddos rule must reference AWSManagedRulesAntiDDoSRuleSet"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.anti_ddos["AWSManagedRulesAntiDDoSRuleSet"].statement[0].managed_rule_group_statement[0].vendor_name == "AWS"
    error_message = "anti_ddos rule must use the AWS vendor"
  }
}

run "anti_ddos_override_count_omits_none" {
  command = plan

  assert {
    condition     = length(aws_wafv2_web_acl_rule.anti_ddos["AWSManagedRulesAntiDDoSRuleSet"].override_action[0].count) == 1
    error_message = "override_action = count should produce a count block"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.anti_ddos["AWSManagedRulesAntiDDoSRuleSet"].override_action[0].none) == 0
    error_message = "override_action = count should not produce a none block"
  }
}

run "anti_ddos_never_challenges_clients" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.anti_ddos["AWSManagedRulesAntiDDoSRuleSet"].statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].usage_of_action == "DISABLED"
    error_message = "anti_ddos must disable the challenge action, so real users never see an interstitial"
  }
}

run "anti_ddos_passes_sensitivity_to_block" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.anti_ddos["AWSManagedRulesAntiDDoSRuleSet"].statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].sensitivity_to_block == "LOW"
    error_message = "sensitivity_to_block did not match input"
  }
}

run "anti_ddos_rejects_unknown_sensitivity" {
  command = plan

  variables {
    anti_ddos_rule = {
      priority             = 5
      override_action      = "count"
      sensitivity_to_block = "EXTREME"
    }
  }

  expect_failures = [var.anti_ddos_rule]
}

run "anti_ddos_rejects_unknown_override_action" {
  command = plan

  variables {
    anti_ddos_rule = {
      priority             = 5
      override_action      = "block"
      sensitivity_to_block = "LOW"
    }
  }

  expect_failures = [var.anti_ddos_rule]
}

run "anti_ddos_null_creates_nothing" {
  command = plan

  variables {
    anti_ddos_rule = null
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.anti_ddos) == 0
    error_message = "expected no anti_ddos rule when anti_ddos_rule is null"
  }
}
