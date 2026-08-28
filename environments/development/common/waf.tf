resource "aws_wafv2_ip_set" "tss_scraper_cf" {
  provider           = aws.us_east_1
  name               = "tss-scraper-cf-${var.environment}"
  description        = "TSS Tariff Scraper rate limit exception, remove after 2027-01-01, HMRC-2501"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = [var.tss_scraper_ip]
}

locals {
  # X-Api-Key values are UUIDs (see GREEN_LANES_API_KEYS in the
  # backend-xi-api-configuration secret). This is a format check, not a
  # validity check against the real keys: it keeps credential material out of
  # the WAF entirely, and the application remains the only place that decides
  # whether a key is genuine and enforces its per-key limit/period. Forging a
  # UUID-shaped header only buys the higher WAF tier, not access.
  api_key_header_regex = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
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

  # Pins TSS at exactly 500 RPM regardless of what var.waf_rpm_limit becomes.
  # allow-tss-scraper (ip_sets_rule below) bypasses the lower general limit.
  # Remove this rule and allow-tss-scraper after 2027-01-01 (HMRC-2501).
  ip_set_rate_based_rules = [
    {
      name       = "tss-scraper-rate-limit"
      priority   = 1
      limit      = 500
      action     = "block"
      ip_set_arn = aws_wafv2_ip_set.tss_scraper_cf.arn
      custom_response = {
        response_code = 429
        body_key      = "rate-limit-exceeded"
        response_header = {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
    }
  ]

  ip_sets_rule = [
    {
      name       = "allow-tss-scraper"
      priority   = 2
      ip_set_arn = aws_wafv2_ip_set.tss_scraper_cf.arn
      action     = "allow"
    }
  ]

  # Two-tier rate limiting. Clients presenting a UUID-shaped X-Api-Key stay on
  # the "ratelimiting" rule above (var.waf_rpm_limit); everyone else is also
  # held to the lower var.waf_no_api_key_rpm_limit here.
  #
  # The negation lives in a separate labelling rule because AWS WAF rejects
  # not_statement inside a rate-based scope_down_statement. label-no-api-key
  # uses a non-terminating count action, so it tags the request and evaluation
  # carries on; a terminating allow would let anyone sending the header skip
  # the managed rule groups (SQLi, bot control) as well as the rate limit.
  #
  # Priorities 11/12 sit after the allow rules at 0-10, so the MCP, TSS, e2e,
  # healthcheck and mycommodities bypasses all keep taking precedence.
  #
  # ROLLOUT: ratelimiting-no-api-key starts as "count" so it is observable in
  # CloudWatch without blocking anything. Size var.waf_no_api_key_rpm_limit
  # against the resulting metrics, then flip the action to "block".
  header_regex_label_rules = [
    {
      name         = "label-no-api-key"
      priority     = 11
      header_name  = "x-api-key"
      regex_string = local.api_key_header_regex
      label        = "no-api-key"
      negate       = true
    }
  ]

  label_rate_based_rules = [
    {
      name     = "ratelimiting-no-api-key"
      priority = 12
      limit    = var.waf_no_api_key_rpm_limit
      action   = "count"
      label    = "no-api-key"
      custom_response = {
        response_code = 429
        body_key      = "rate-limit-exceeded"
        response_header = {
          name  = "X-Rate-Limit"
          value = "1"
        }
      }
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
  retention_in_days = 7
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
