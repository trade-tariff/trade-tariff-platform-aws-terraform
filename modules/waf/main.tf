# https://docs.aws.amazon.com/waf/latest/developerguide/how-aws-waf-works.html

locals {
  filtered_header_rules = {
    for i, header_name in var.filtered_header_rule.header_types :
    replace(header_name, ".", "-") => {
      priority     = var.filtered_header_rule.priority + i + 1
      name         = header_name
      header_value = var.filtered_header_rule.header_value
      action       = var.filtered_header_rule.action
    }
  }
}

resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = "WAFv2 ACL for ${var.name}"
  scope       = var.scope

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

  # Do NOT remove - required permanently as long as any rule is managed
  # via a standalone aws_wafv2_web_acl_rule resource (see HMRC-2529).
  # Removing this without first re-adding matching inline `rule` blocks
  # will cause Terraform to see rule = [] in config and plan to delete
  # every rule in the Web ACL, not just unmigrated ones.
  lifecycle { ignore_changes = [rule] }

  tags = var.tags
}

resource "aws_wafv2_regex_pattern_set" "this" {
  name        = "assets-${var.name}"
  description = "Web application assets regex pattern set"
  scope       = var.scope

  regular_expression {
    regex_string = "^.*\\.(js|map|css|png|jpg|jpeg|gif|svg)$"
  }

  regular_expression {
    regex_string = "^.*\\/(assets|images)\\/.*$"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  count = var.associate_alb ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# ---------------------------------------------------------------------
# Standalone rule resources for rules migrated from inline Web ACL rules.
# These are managed independently of the Web ACL resource to allow
# for more granular control over rule lifecycle and to avoid Terraform
# attempting to delete and recreate rules unnecessarily when the Web ACL
# is updated.
# ---------------------------------------------------------------------

resource "aws_wafv2_web_acl_rule" "allow_assets_from_rate_limit" {
  for_each = var.ip_rate_based_rule != null ? { "allow-assets-from-rate-limit" = var.ip_rate_based_rule } : {}

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = "allow-assets-from-rate-limit"
  priority    = each.value.priority - 1

  action {
    allow {}
  }

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

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "allow-assets-from-rate-limit"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "ip_rate_based" {
  for_each = var.ip_rate_based_rule != null ? { (var.ip_rate_based_rule.name) = var.ip_rate_based_rule } : {}

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  action {
    dynamic "count" {
      for_each = each.value.action == "count" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = each.value.action == "block" ? [1] : []
      content {
        custom_response {
          custom_response_body_key = each.value.custom_response.body_key
          response_code            = each.value.custom_response.response_code
          response_header {
            name  = each.value.custom_response.response_header.name
            value = each.value.custom_response.response_header.value
          }
        }
      }
    }
  }

  statement {
    rate_based_statement {
      limit                 = each.value.rpm_limit
      evaluation_window_sec = 60
      aggregate_key_type    = "IP"
      # scope_down_statement removed - asset exclusion now handled by
      # allow_assets_from_rate_limit above instead of a not_statement here.
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "ip_sets" {
  for_each = { for r in var.ip_sets_rule : r.name => r }

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  action {
    dynamic "allow" {
      for_each = each.value.action == "allow" ? [1] : []
      content {}
    }

    dynamic "count" {
      for_each = each.value.action == "count" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = each.value.action == "block" ? [1] : []
      content {}
    }
  }

  statement {
    ip_set_reference_statement {
      arn = each.value.ip_set_arn
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "ip_rate_url_based" {
  for_each = { for r in var.ip_rate_url_based_rules : r.name => r }

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  action {
    dynamic "allow" {
      for_each = each.value.action == "allow" ? [1] : []
      content {}
    }

    dynamic "count" {
      for_each = each.value.action == "count" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = each.value.action == "block" ? [1] : []
      content {}
    }
  }

  statement {
    rate_based_statement {
      limit              = each.value.limit
      aggregate_key_type = "IP"
      scope_down_statement {
        byte_match_statement {
          positional_constraint = each.value.positional_constraint
          search_string         = each.value.search_string
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
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "filtered_header" {
  for_each = local.filtered_header_rules

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.key
  priority    = each.value.priority

  action {
    dynamic "allow" {
      for_each = each.value.action == "allow" ? [1] : []
      content {}
    }

    dynamic "count" {
      for_each = each.value.action == "count" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = each.value.action == "block" ? [1] : []
      content {}
    }
  }

  statement {
    byte_match_statement {
      field_to_match {
        single_header {
          name = each.value.name
        }
      }
      positional_constraint = "EXACTLY"
      search_string         = each.value.header_value
      text_transformation {
        priority = each.value.priority
        type     = "COMPRESS_WHITE_SPACE"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.key
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "group_rules" {
  for_each = { for r in var.group_rules : r.name => r }

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  override_action {
    dynamic "none" {
      for_each = each.value.override_action == "none" ? [1] : []
      content {}
    }

    dynamic "count" {
      for_each = each.value.override_action == "count" ? [1] : []
      content {}
    }
  }

  statement {
    rule_group_reference_statement {
      arn = each.value.arn

      dynamic "rule_action_override" {
        for_each = each.value.excluded_rules
        content {
          name = rule_action_override.value
          action_to_use {
            count {}
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "uri_path_match" {
  for_each = { for r in var.uri_path_match_rules : r.name => r }

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  action {
    dynamic "allow" {
      for_each = each.value.action == "allow" ? [1] : []
      content {}
    }
    dynamic "count" {
      for_each = each.value.action == "count" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = each.value.action == "block" ? [1] : []
      content {}
    }
  }

  statement {
    byte_match_statement {
      positional_constraint = each.value.positional_constraint
      search_string         = each.value.search_string

      field_to_match {
        uri_path {}
      }

      text_transformation {
        priority = 0
        type     = "NONE"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "header_allow" {
  for_each = { for r in var.header_allow_rules : r.name => r }

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  action {
    allow {}
  }

  statement {
    byte_match_statement {
      positional_constraint = "EXACTLY"
      search_string         = var.header_allow_values[each.value.name] # sensitive lookup stays isolated here

      field_to_match {
        single_header {
          name = lower(each.value.header_name)
        }
      }

      text_transformation {
        priority = 0
        type     = "NONE"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "host_path_allow" {
  for_each = {
    for rule in var.host_path_allow_rules : rule.name => rule
  }

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  action {
    allow {}
  }

  statement {
    and_statement {
      statement {
        byte_match_statement {
          positional_constraint = "EXACTLY"
          search_string         = each.value.host

          field_to_match {
            single_header {
              name = "host"
            }
          }

          text_transformation {
            priority = 0
            type     = "LOWERCASE"
          }
        }
      }

      statement {
        byte_match_statement {
          positional_constraint = each.value.positional_constraint
          search_string         = each.value.path_search_string

          field_to_match {
            uri_path {}
          }

          text_transformation {
            priority = 0
            type     = "NONE"
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "managed_rule_path_exceptions" {
  for_each = {
    for exception in var.managed_rule_path_exceptions : exception.name => exception
  }

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.value.name
  priority    = each.value.priority

  action {
    block {}
  }

  statement {
    and_statement {
      statement {
        label_match_statement {
          key   = each.value.label
          scope = "LABEL"
        }
      }
      statement {
        not_statement {
          statement {
            and_statement {
              statement {
                byte_match_statement {
                  positional_constraint = "EXACTLY"
                  search_string         = each.value.excluded_uri_path
                  field_to_match {
                    uri_path {}
                  }
                  text_transformation {
                    priority = 0
                    type     = "NONE"
                  }
                }
              }
              statement {
                byte_match_statement {
                  positional_constraint = "EXACTLY"
                  search_string         = each.value.excluded_http_method
                  field_to_match {
                    method {}
                  }
                  text_transformation {
                    priority = 0
                    type     = "NONE"
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.value.name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "managed" {
  for_each = var.managed_rules

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = each.key
  priority    = each.value.priority

  override_action {
    dynamic "none" {
      for_each = each.value.override_action == "none" ? [1] : []
      content {}
    }
    dynamic "count" {
      for_each = each.value.override_action == "count" ? [1] : []
      content {}
    }
  }

  statement {
    managed_rule_group_statement {
      name        = each.key
      vendor_name = "AWS"

      dynamic "rule_action_override" {
        for_each = toset(concat(
          each.value.excluded_rules,
          [
            for exception in var.managed_rule_path_exceptions : exception.managed_rule
            if exception.managed_rule_group == each.key
          ],
        ))
        content {
          name = rule_action_override.value
          action_to_use {
            count {}
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = each.key
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "allow_bot_control_excluded_paths" {
  # INVARIANT: This rule's priority MUST remain lower than every other ACL rule.
  #
  # `action { allow {} }` stops WAF evaluation completely. Excluded paths
  # therefore bypass all higher-priority rules, not just Bot Control.
  #
  # This is safe only while Bot Control is the highest-priority rule. If a
  # higher-priority rule is added later, excluded paths will silently bypass
  # it as well. AWS WAFv2 cannot scope this exclusion to Bot Control alone
  # because managed rule group `scope_down_statement` does not support the
  # required logical statements. See HMRC-2529.
  #
  # Enforced by the "bot control remains highest priority rule" test in
  # `modules/waf/tests/bot_control.tftest.hcl`.
  for_each = var.bot_control_rule != null && length(var.bot_control_rule.excluded_uri_prefixes) > 0 ? {
    "allow-bot-control-excluded-paths" = var.bot_control_rule
  } : {}


  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = "allow-bot-control-excluded-paths"
  priority    = var.bot_control_rule.priority - 1

  action {
    allow {}
  }

  statement {
    or_statement {
      dynamic "statement" {
        for_each = var.bot_control_rule.excluded_uri_prefixes
        content {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string         = statement.value
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "allow-bot-control-excluded-paths"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "bot_control" {
  for_each = var.bot_control_rule != null ? { "AWSManagedRulesBotControlRuleSet" = var.bot_control_rule } : {}

  web_acl_arn = aws_wafv2_web_acl.this.arn
  name        = "AWSManagedRulesBotControlRuleSet"
  priority    = each.value.priority # 70 — must stay after the allow rule above

  override_action {
    dynamic "none" {
      for_each = each.value.override_action == "none" ? [1] : []
      content {}
    }
    dynamic "count" {
      for_each = each.value.override_action == "count" ? [1] : []
      content {}
    }
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesBotControlRuleSet"
      vendor_name = "AWS"

      managed_rule_group_configs {
        aws_managed_rules_bot_control_rule_set {
          inspection_level        = each.value.inspection_level
          enable_machine_learning = each.value.enable_machine_learning
        }
      }

      dynamic "rule_action_override" {
        for_each = toset(each.value.captcha_override_rules)
        content {
          name = rule_action_override.key
          action_to_use {
            challenge {}
          }
        }
      }
      # scope_down_statement removed — exclusion now handled by the
      # preceding allow rule above instead of a not_statement here.
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWSManagedRulesBotControlRuleSet"
    sampled_requests_enabled   = true
  }
}
