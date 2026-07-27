mock_provider "aws" {}

run "host_path_allow_created_with_expected_shape" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    host_path_allow_rules = [
      {
        name                  = "allow-partner-host"
        priority              = 15
        host                  = "partner.example.com"
        path_search_string    = "/webhooks/"
        positional_constraint = "STARTS_WITH"
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.host_path_allow["allow-partner-host"].priority == 15
    error_message = "host_path_allow rule priority did not match input"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.host_path_allow["allow-partner-host"].statement[0].and_statement[0].statement[0].byte_match_statement[0].search_string == "partner.example.com"
    error_message = "host match search_string should be the host value"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.host_path_allow["allow-partner-host"].statement[0].and_statement[0].statement[1].byte_match_statement[0].search_string == "/webhooks/"
    error_message = "path match search_string should be the path_search_string value"
  }
}

run "host_path_allow_uses_lowercase_host_header" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    host_path_allow_rules = [
      {
        name                  = "allow-partner-host"
        priority              = 15
        host                  = "Partner.Example.com"
        path_search_string    = "/webhooks/"
        positional_constraint = "STARTS_WITH"
      }
    ]
  }

  # host match must use LOWERCASE text transformation, since AWS WAF
  # compares header values case-sensitively otherwise and "host" headers
  # are conventionally lowercase on the wire
  assert {
    condition     = aws_wafv2_web_acl_rule.host_path_allow["allow-partner-host"].statement[0].and_statement[0].statement[0].byte_match_statement[0].text_transformation[0].type == "LOWERCASE"
    error_message = "host match must use LOWERCASE text transformation"
  }
}

run "host_path_allow_empty_list_creates_nothing" {
  command = plan

  variables {
    name                  = "test-waf"
    scope                 = "CLOUDFRONT"
    host_path_allow_rules = []
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.host_path_allow) == 0
    error_message = "expected no host_path_allow rules when list is empty"
  }
}
