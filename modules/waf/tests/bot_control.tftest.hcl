run "bot_control_zero_excluded_prefixes_creates_no_allow_rule" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "REGIONAL"

    bot_control_rule = {
      priority                = 70
      override_action         = "none"
      inspection_level        = "COMMON"
      enable_machine_learning = false
      excluded_uri_prefixes   = []
      captcha_override_rules  = []
    }
  }

  # regression test for HMRC-2529: an empty excluded_uri_prefixes list
  # must NOT produce an invalid or_statement with zero nested statements
  assert {
    condition     = length(aws_wafv2_web_acl_rule.allow_bot_control_excluded_paths) == 0
    error_message = "expected no allow-rule when excluded_uri_prefixes is empty"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.bot_control) == 1
    error_message = "bot_control rule should still be created even with zero exclusions"
  }
}

run "bot_control_allow_rule_priority_tracks_bot_control_priority" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "REGIONAL"

    bot_control_rule = {
      priority                = 55  # deliberately non-default, to prove it's computed not hardcoded
      override_action         = "none"
      inspection_level        = "COMMON"
      enable_machine_learning = false
      excluded_uri_prefixes   = ["/api/", "/healthcheck"]
      captcha_override_rules  = []
    }
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.allow_bot_control_excluded_paths["allow-bot-control-excluded-paths"].priority == 54
    error_message = "allow-rule priority must always be bot_control priority minus 1"
  }
}

# INVARIANT test - see code comment above allow_bot_control_excluded_paths
# in main.tf. This uses the module's actual default var value, so it
# exercises the real production shape, not just an arbitrary test fixture.
run "bot_control_remains_highest_priority_rule_in_defaults" {
  command = plan

  # uses variable defaults as defined in variables.tf, mirroring the
  # production module call as closely as possible
  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    bot_control_rule = {
      priority                = 70
      override_action         = "none"
      inspection_level        = "COMMON"
      enable_machine_learning = false
      excluded_uri_prefixes   = ["/uk/api/", "/xi/api/", "/api/"]
      captcha_override_rules  = []
    }

    ip_rate_based_rule = {
      name      = "ratelimiting"
      priority  = 1
      rpm_limit = 1000
      action    = "block"
      custom_response = {
        response_code = 429
        body_key      = "rate-limit-exceeded"
        response_header = {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
    }
  }

  assert {
    condition = alltrue([
      for r in aws_wafv2_web_acl_rule.managed : r.priority < var.bot_control_rule.priority
    ])
    error_message = "A managed rule group has priority >= bot_control - the terminating allow rule at bot_control.priority-1 would silently bypass it"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.bot_control["AWSManagedRulesBotControlRuleSet"].priority == 70
    error_message = "bot_control priority changed - re-verify it's still the highest priority in the ACL, or the exclusion invariant is broken"
  }
}