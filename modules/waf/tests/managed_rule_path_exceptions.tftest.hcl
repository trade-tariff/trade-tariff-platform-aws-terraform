mock_provider "aws" {}

run "managed_rule_path_exception_counts_and_reblocks" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    managed_rule_path_exceptions = [
      {
        name                 = "block-sqli-body-except-search"
        priority             = 55
        managed_rule_group   = "AWSManagedRulesSQLiRuleSet"
        managed_rule         = "SQLi_BODY"
        label                = "awswaf:managed:aws:sql-database:SQLi_Body"
        excluded_uri_path    = "/search"
        excluded_http_method = "POST"
      },
    ]
  }

  assert {
    condition = length([
      for override in aws_wafv2_web_acl_rule.managed["AWSManagedRulesSQLiRuleSet"].statement[0].managed_rule_group_statement[0].rule_action_override : override
      if override.name == "SQLi_BODY" &&
      length(override.action_to_use[0].count) == 1
    ]) == 1

    error_message = "SQLi_BODY must be overridden to Count so its managed-rule label remains available."
  }

  assert {
    condition = (
      aws_wafv2_web_acl_rule.managed_rule_path_exceptions["block-sqli-body-except-search"].priority == 55 &&
      length(aws_wafv2_web_acl_rule.managed_rule_path_exceptions["block-sqli-body-except-search"].action[0].block) == 1
    )

    error_message = "The exception must add a blocking rule at priority 55."
  }

  assert {
    condition = length([
      for statement in aws_wafv2_web_acl_rule.managed_rule_path_exceptions["block-sqli-body-except-search"].statement[0].and_statement[0].statement : statement
      if try(statement.label_match_statement[0].scope, null) == "LABEL" &&
      try(statement.label_match_statement[0].key, null) == "awswaf:managed:aws:sql-database:SQLi_Body"
    ]) == 1

    error_message = "The exception must match the SQLi_BODY managed-rule label."
  }

  assert {
    condition = length([
      for statement in aws_wafv2_web_acl_rule.managed_rule_path_exceptions["block-sqli-body-except-search"].statement[0].and_statement[0].statement : statement
      if length([
        for exception_statement in try(statement.not_statement[0].statement[0].and_statement[0].statement, []) : exception_statement
        if try(exception_statement.byte_match_statement[0].positional_constraint, null) == "EXACTLY" &&
        try(exception_statement.byte_match_statement[0].search_string, null) == "/search" &&
        length(try(exception_statement.byte_match_statement[0].field_to_match[0].uri_path, [])) == 1
      ]) == 1
    ]) == 1

    error_message = "The managed label must be re-blocked everywhere except the exact /search URI path."
  }

  assert {
    condition = length([
      for statement in aws_wafv2_web_acl_rule.managed_rule_path_exceptions["block-sqli-body-except-search"].statement[0].and_statement[0].statement : statement
      if length([
        for exception_statement in try(statement.not_statement[0].statement[0].and_statement[0].statement, []) : exception_statement
        if try(exception_statement.byte_match_statement[0].search_string, null) == "POST" &&
        length(try(exception_statement.byte_match_statement[0].field_to_match[0].method, [])) == 1
      ]) == 1
    ]) == 1

    error_message = "The managed label exception must be restricted to POST requests."
  }
}

run "rejects_unknown_managed_rule_group" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    managed_rule_path_exceptions = [
      {
        name                 = "invalid-unknown-group"
        priority             = 55
        managed_rule_group   = "AWSManagedRulesMissingRuleSet"
        managed_rule         = "SQLi_BODY"
        label                = "awswaf:managed:aws:sql-database:SQLi_Body"
        excluded_uri_path    = "/search"
        excluded_http_method = "POST"
      },
    ]
  }

  expect_failures = [var.managed_rule_path_exceptions]
}

run "rejects_exception_before_managed_rule_group" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    managed_rule_path_exceptions = [
      {
        name                 = "invalid-rule-order"
        priority             = 49
        managed_rule_group   = "AWSManagedRulesSQLiRuleSet"
        managed_rule         = "SQLi_BODY"
        label                = "awswaf:managed:aws:sql-database:SQLi_Body"
        excluded_uri_path    = "/search"
        excluded_http_method = "POST"
      },
    ]
  }

  expect_failures = [var.managed_rule_path_exceptions]
}
