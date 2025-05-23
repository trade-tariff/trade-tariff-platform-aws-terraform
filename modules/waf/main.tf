# https://docs.aws.amazon.com/waf/latest/developerguide/how-aws-waf-works.html
provider "aws" {
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = "WAFv2 ACL for ${var.name}"

  scope = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  custom_response_body {
    key          = "rate-limit-exceeded"
    content      = "You have exceeded the permitted number of requests. Please try again later"
    content_type = "TEXT_PLAIN"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = var.name
  }

  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.key
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.key
          vendor_name = "AWS"

          dynamic "rule_action_override" {
            for_each = toset(rule.value.excluded_rules)
            content {
              name = rule_action_override.key
              action_to_use {
                count {}
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.key
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_sets_rule
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        ip_set_reference_statement {
          arn = rule.value.ip_set_arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_rate_based_rule != null ? [var.ip_rate_based_rule] : []
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {
            # Nothing to do, these go into Cloudwatch
          }
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            custom_response {
              custom_response_body_key = rule.value.custom_response.body_key
              response_code            = rule.value.custom_response.response_code
              response_header {
                name  = rule.value.custom_response.response_header.name
                value = rule.value.custom_response.response_header.value
              }
            }
          }
        }

      }

      statement {
        rate_based_statement {
          limit                 = rule.value.rpm_limit
          evaluation_window_sec = 60
          aggregate_key_type    = "IP"

          # NOTE: This block will exclude assets from the rate limiting rules since these are all cached in the CDN.
          scope_down_statement {
            not_statement {
              statement {
                regex_pattern_set_reference_statement {
                  arn = aws_wafv2_regex_pattern_set.this.arn
                  field_to_match {
                    uri_path {}
                  }
                  text_transformation {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_rate_url_based_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          limit              = rule.value.limit
          aggregate_key_type = "IP"
          scope_down_statement {
            byte_match_statement {
              positional_constraint = rule.value.positional_constraint
              search_string         = rule.value.search_string
              field_to_match {
                uri_path {}
              }
              text_transformation {
                priority = 0
                type     = "URL_DECODE"
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = [for header_name in var.filtered_header_rule.header_types : {
      priority     = var.filtered_header_rule.priority + index(var.filtered_header_rule.header_types, header_name) + 1
      name         = header_name
      header_value = var.filtered_header_rule.header_value
      action       = var.filtered_header_rule.action
    }]

    content {
      name     = replace(rule.value.name, ".", "-")
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        byte_match_statement {
          field_to_match {
            single_header {
              name = rule.value.header_value
            }
          }
          positional_constraint = "EXACTLY"
          search_string         = rule.value.name
          text_transformation {
            priority = rule.value.priority
            type     = "COMPRESS_WHITE_SPACE"
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = replace(rule.value.name, ".", "-")
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.group_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        rule_group_reference_statement {
          arn = rule.value.arn

          dynamic "rule_action_override" {
            for_each = rule.value.excluded_rules
            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  tags = var.tags
}

resource "aws_wafv2_regex_pattern_set" "this" {
  name        = "assets"
  description = "Web application assets regex pattern set"
  scope       = var.scope

  regular_expression {
    regex_string = "^.*\\.(js|map|css|png|jpg|jpeg|gif|svg)$"
  }

  regular_expression {
    regex_string = "^.*\\/(assets|images)\\/.*$"
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  count = var.associate_alb ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
