module "waf" {
  source = "../../../modules/waf"

  providers = {
    aws = aws.us_east_1
  }

  name  = "tariff-waf-${var.environment}"
  scope = "CLOUDFRONT"

  ip_rate_based_rule = {
    name      = "ratelimiting"
    priority  = 1
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

  header_allow_rules = var.waf_mcp_secret_token != "" ? [
    {
      name         = "allow-mcp-server"
      priority     = 0
      header_name  = "x-mcp-token"
      header_value = var.waf_mcp_secret_token
    }
  ] : []

  uri_path_match_rules = [
    {
      name                  = "allow-mycommodities-path"
      priority              = 9
      action                = "allow"
      search_string         = "/subscriptions/mycommodities"
      positional_constraint = "CONTAINS"
    }
  ]

  # Allow OAuth endpoints on the MCP domain through managed rules.
  # Managed rules (priority 10+) can block legitimate OAuth POST requests
  # (e.g. CommonRuleSet body inspection). These allow rules fire at priority
  # 2-3, before managed rules, so the OAuth flow is never incorrectly blocked.
  host_path_allow_rules = [
    {
      name                  = "allow-mcp-oauth-token"
      priority              = 2
      host                  = "mcp.${var.domain_name}"
      path_search_string    = "/token"
      positional_constraint = "EXACTLY"
    },
    {
      name                  = "allow-mcp-oauth-authorize"
      priority              = 3
      host                  = "mcp.${var.domain_name}"
      path_search_string    = "/authorize"
      positional_constraint = "STARTS_WITH"
    },
  ]
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  provider          = aws.us_east_1
  name              = "aws-waf-logs-tariff-${var.environment}"
  retention_in_days = 60
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
  provider = aws.us_east_1

  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = module.waf.web_acl_id

  logging_filter {
    default_behavior = "KEEP"

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
