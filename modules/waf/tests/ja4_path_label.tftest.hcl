mock_provider "aws" {}

variables {
  name  = "test-waf"
  scope = "CLOUDFRONT"

  ja4_path_label_rules = [
    {
      name              = "label-no-alpn-pages"
      priority          = 13
      ja4_regex_string  = "^[tqd][0-9a-z]{2}[di][0-9]{4}00_"
      path_regex_string = "^/(uk/|xi/)?commodities/"
      label             = "no-alpn-page"
    }
  ]
}

run "ja4_path_label_rule_counts_and_labels" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.ja4_path_label["label-no-alpn-pages"].priority == 13
    error_message = "ja4_path_label rule priority did not match input"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ja4_path_label["label-no-alpn-pages"].action[0].count) == 1
    error_message = "ja4_path_label rule must use the non-terminating count action"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ja4_path_label["label-no-alpn-pages"].rule_label[0].name == "no-alpn-page"
    error_message = "ja4_path_label rule must add the given label"
  }
}

run "ja4_path_label_rule_matches_ja4_and_path" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl_rule.ja4_path_label["label-no-alpn-pages"].statement[0].and_statement[0].statement[0].regex_match_statement[0].regex_string == "^[tqd][0-9a-z]{2}[di][0-9]{4}00_"
    error_message = "first statement should match the JA4 regex"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ja4_path_label["label-no-alpn-pages"].statement[0].and_statement[0].statement[0].regex_match_statement[0].field_to_match[0].ja4_fingerprint[0].fallback_behavior == "NO_MATCH"
    error_message = "JA4 statement should inspect the JA4 fingerprint and not match when WAF cannot compute it"
  }

  assert {
    condition     = aws_wafv2_web_acl_rule.ja4_path_label["label-no-alpn-pages"].statement[0].and_statement[0].statement[1].regex_match_statement[0].regex_string == "^/(uk/|xi/)?commodities/"
    error_message = "second statement should match the path regex"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ja4_path_label["label-no-alpn-pages"].statement[0].and_statement[0].statement[1].regex_match_statement[0].field_to_match[0].uri_path) == 1
    error_message = "path statement should inspect the URI path"
  }
}

run "ja4_path_label_rejects_reserved_label" {
  command = plan

  variables {
    ja4_path_label_rules = [
      {
        name              = "label-no-alpn-pages"
        priority          = 13
        ja4_regex_string  = "^[tqd][0-9a-z]{2}[di][0-9]{4}00_"
        path_regex_string = "^/commodities/"
        label             = "awswaf"
      }
    ]
  }

  expect_failures = [var.ja4_path_label_rules]
}

run "ja4_path_label_empty_list_creates_nothing" {
  command = plan

  variables {
    ja4_path_label_rules = []
  }

  assert {
    condition     = length(aws_wafv2_web_acl_rule.ja4_path_label) == 0
    error_message = "expected no ja4_path_label rules when list is empty"
  }
}
