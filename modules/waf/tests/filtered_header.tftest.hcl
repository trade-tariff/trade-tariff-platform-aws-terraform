mock_provider "aws" {}

run "filtered_header_fields_not_inverted" {
  command = plan

  variables {
    name  = "test-waf"
    scope = "CLOUDFRONT"

    filtered_header_rule = {
      priority     = 100
      header_types = ["User-Agent"]
      header_value = "BadBot/1.0"
      action       = "block"
    }
  }

  # single_header.name must be the header NAME being inspected,
  # search_string must be the VALUE being matched against it.
  # (regression test for the swapped-fields bug fixed in HMRC-2529)
  assert {
    condition     = aws_wafv2_web_acl_rule.filtered_header["User-Agent"].statement[0].byte_match_statement[0].field_to_match[0].single_header[0].name == "User-Agent"
    error_message = "single_header.name should be the header name, not the header value"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.filtered_header["User-Agent"].statement[0].byte_match_statement[0].search_string == "BadBot/1.0"
    error_message = "search_string should be the header value, not the header name"
  }
}
