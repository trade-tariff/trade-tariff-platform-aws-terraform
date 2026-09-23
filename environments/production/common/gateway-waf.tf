locals {
  mcp_apigw_exemption_enabled = nonsensitive(var.waf_mcp_secret_token != "")

  apigw_rate_limit_response = {
    response_code = 429
    body_key      = "rate-limit-exceeded"
    response_header = {
      name  = "X-Rate-Limit"
      value = "1"
    }
  }
}

module "waf_apigw" {
  source = "../../../modules/waf"

  providers = {
    aws = aws
  }

  name  = "tariff-apigw-waf-${var.environment}"
  scope = "REGIONAL"

  associate_alb = false

  # Per-IP rate limit. All MCP traffic leaves through one NAT IP, so a plain
  # per-IP limit would 429 MCP long before the shared MCP usage plan in
  # gateway.tf. When the MCP token is configured, label-non-mcp tags every
  # request that does NOT carry the exact X-Mcp-Token value, and the rate limit
  # applies only to that label. MCP traffic is then limited by its usage plan
  # instead.
  #
  # label-non-mcp is a non-terminating count rule, so MCP traffic still goes
  # through the managed rule groups. The authorizer validates the token again.
  #
  # Without the token, the plain ip-rate-limit rule applies to all traffic, as
  # before.
  ip_rate_based_rule = local.mcp_apigw_exemption_enabled ? null : {
    name            = "ip-rate-limit"
    priority        = 3
    rpm_limit       = var.waf_apigw_rpm_limit
    action          = "block"
    custom_response = local.apigw_rate_limit_response
  }

  header_mismatch_label_rules = local.mcp_apigw_exemption_enabled ? [
    {
      name        = "label-non-mcp"
      priority    = 2
      header_name = "x-mcp-token"
      label       = "non-mcp"
    }
  ] : []

  header_mismatch_label_values = local.mcp_apigw_exemption_enabled ? { "label-non-mcp" = var.waf_mcp_secret_token } : {}

  label_rate_based_rules = local.mcp_apigw_exemption_enabled ? [
    {
      name            = "ip-rate-limit-non-mcp"
      priority        = 4
      limit           = var.waf_apigw_rpm_limit
      action          = "block"
      label           = "non-mcp"
      custom_response = local.apigw_rate_limit_response
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
}

resource "aws_wafv2_web_acl_association" "apigw" {
  resource_arn = module.gateway.api_gateway_stage_arn
  web_acl_arn  = module.waf_apigw.web_acl_id
}

resource "aws_cloudwatch_log_group" "apigw_waf_logs" {
  name              = "aws-waf-logs-apigw-${var.environment}"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "apigw_waf_logging" {
  resource_arn            = module.waf_apigw.web_acl_id
  log_destination_configs = [aws_cloudwatch_log_group.apigw_waf_logs.arn]

  depends_on = [aws_cloudwatch_log_resource_policy.apigw_waf_logs]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    method {}
  }

  # X-Mcp-Token exempts a request from the per-IP rate limit above. Keep it
  # out of the logs so a log reader cannot copy it.
  redacted_fields {
    single_header {
      name = "x-mcp-token"
    }
  }
}

data "aws_iam_policy_document" "apigw_waf_log_group_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AWSWAFLoggingPermissions"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "wafv2.amazonaws.com",
        "waf-regional.amazonaws.com"
      ]
    }

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.apigw_waf_logs.arn}:*"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:wafv2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:regional/webacl/*"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "apigw_waf_logs" {
  policy_name     = "tariff-apigw-waf-logs-policy-${var.environment}"
  policy_document = data.aws_iam_policy_document.apigw_waf_log_group_policy.json
}
