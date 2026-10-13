mock_provider "aws" {}

run "header_country_match_combines_header_and_country" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_country_match_rules = [
      {
        name                  = "block-test-ua"
        priority              = 22
        action                = "block"
        header_name           = "User-Agent"
        search_string         = "BadBot/1.0"
        positional_constraint = "CONTAINS"
        country_codes         = ["US"]
      }
    ]
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_country_match["block-test-ua"].statement[0].and_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_header[0].name == "user-agent"
    error_message = "single_header.name should be the lower-case header name"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_country_match["block-test-ua"].statement[0].and_statement[0].statement[0].byte_match_statement[0].search_string == "BadBot/1.0"
    error_message = "search_string should be the header value"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.header_country_match["block-test-ua"].statement[0].and_statement[0].statement[1].geo_match_statement[0].country_codes == tolist(["US"])
    error_message = "geo_match_statement should use the given country codes"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.header_country_match["block-test-ua"].action[0].block) == 1
    error_message = "action should be block"
  }
}

run "header_country_match_rejects_allow_action" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    header_country_match_rules = [
      {
        name                  = "allow-test-ua"
        priority              = 22
        action                = "allow"
        header_name           = "User-Agent"
        search_string         = "BadBot/1.0"
        positional_constraint = "CONTAINS"
        country_codes         = ["US"]
      }
    ]
  }

  expect_failures = [var.header_country_match_rules]
}
