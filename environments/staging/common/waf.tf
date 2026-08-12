resource "aws_wafv2_ip_set" "tss_scraper_cf" {
  provider           = aws.us_east_1
  name               = "tss-scraper-cf-${var.environment}"
  description        = "TSS Tariff Scraper rate limit exception, remove after 2027-01-01, HMRC-2501"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["208.127.47.194/32"]
}

module "waf" {
  source = "../../../modules/waf"

  providers = {
    aws = aws.us_east_1
  }

  name  = "tariff-waf-${var.environment}"
  scope = "CLOUDFRONT"

  ip_rate_based_rule = {
    name      = "ratelimiting"
    priority  = 4
    rpm_limit = var.waf_rpm_limit
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

  ip_sets_rule = [
    {
      name       = "allow-tss-scraper"
      priority   = 2
      ip_set_arn = aws_wafv2_ip_set.tss_scraper_cf.arn
      action     = "allow"
    }
  ]

  header_allow_rules = concat(
    nonsensitive(var.waf_mcp_secret_token != "") ? [
      {
        name        = "allow-mcp-server"
        priority    = 0
        header_name = "x-mcp-token"
      }
    ] : [],
    nonsensitive(var.WAF_E2E_SECRET_TOKEN != "") ? [
      {
        name        = "allow-e2e-tests"
        priority    = 8
        header_name = "x-waf-bypass"
      }
    ] : []
  )

  header_allow_values = merge(
    var.waf_mcp_secret_token != "" ? { "allow-mcp-server" = var.waf_mcp_secret_token } : {},
    var.WAF_E2E_SECRET_TOKEN != "" ? { "allow-e2e-tests" = var.WAF_E2E_SECRET_TOKEN } : {}
  )

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

  uri_path_match_rules = [
    {
      name                  = "allow-healthcheck"
      priority              = 9
      action                = "allow"
      search_string         = "/healthcheck"
      positional_constraint = "EXACTLY"
    },
    {
      name                  = "allow-mycommodities-path"
      priority              = 10
      action                = "allow"
      search_string         = "/subscriptions/mycommodities"
      positional_constraint = "CONTAINS"
    }
  ]

}

resource "aws_cloudwatch_log_group" "waf_logs" {
  provider          = aws.us_east_1
  name              = "aws-waf-logs-tariff-${var.environment}"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
  provider = aws.us_east_1

  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = module.waf.web_acl_id

  logging_filter {
    default_behavior = "DROP"

    # to remove noise in log group, since we are not blocking for no user agent
    # header and instead COUNTing, drop all NoUserAgent_Header logs where rule
    # action is COUNT.

    filter {
      behavior = "DROP"

      condition {
        label_name_condition {
          label_name = "awswaf:managed:aws:core-rule-set:NoUserAgent_Header"
        }
      }

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      requirement = "MEETS_ALL"
    }

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}

data "aws_iam_policy_document" "waf_log_group_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.waf_logs.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "waf_logs" {
  policy_document = data.aws_iam_policy_document.waf_log_group_policy.json
  policy_name     = "tariff-waf-logs-policy-${var.environment}"
}

# Pins TSS at exactly 500 RPM regardless of what var.waf_rpm_limit becomes.
# The allow-tss-scraper rule (priority 2) then bypasses the lower general limit.
# Remove this rule and allow-tss-scraper after 2027-01-01 (HMRC-2501).
resource "aws_wafv2_web_acl_rule" "tss_scraper_rate_limit_cf" {
  provider    = aws.us_east_1
  web_acl_arn = module.waf.web_acl_id
  name        = "tss-scraper-rate-limit"
  priority    = 1

  action {
    block {
      custom_response {
        custom_response_body_key = "rate-limit-exceeded"
        response_code            = 429
        response_header {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
    }
  }

  statement {
    rate_based_statement {
      limit                 = 500
      evaluation_window_sec = 60
      aggregate_key_type    = "IP"
      scope_down_statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.tss_scraper_cf.arn
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "tss-scraper-rate-limit"
    sampled_requests_enabled   = true
  }
}
