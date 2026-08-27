mock_provider "aws" {}

run "header_allow_multi_single_value" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_allow_multi_rules = [
      { name = "allow-api-key", priority = 3, header_name = "x-api-key" }
    ]
    header_allow_multi_values = {
      "allow-api-key" = ["test-key-one"]
    }
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_allow_multi["allow-api-key"].priority == 3
    error_message = "header_allow_multi rule priority mismatch"
  }
}

run "header_allow_multi_several_values" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_allow_multi_rules = [
      { name = "allow-api-key", priority = 3, header_name = "x-api-key" }
    ]
    header_allow_multi_values = {
      "allow-api-key" = ["test-key-one", "test-key-two", "test-key-three"]
    }
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_allow_multi["allow-api-key"].priority == 3
    error_message = "header_allow_multi rule priority mismatch"
  }
}

run "header_allow_multi_missing_value_fails_validation" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_allow_multi_rules = [
      { name = "allow-api-key", priority = 3, header_name = "x-api-key" }
    ]
    header_allow_multi_values = {} # deliberately missing the matching entry
  }

  expect_failures = [
    var.header_allow_multi_values,
  ]
}

run "header_allow_multi_empty_list_fails_validation" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_allow_multi_rules = [
      { name = "allow-api-key", priority = 3, header_name = "x-api-key" }
    ]
    header_allow_multi_values = {
      "allow-api-key" = [] # deliberately empty
    }
  }

  expect_failures = [
    var.header_allow_multi_values,
  ]
}
