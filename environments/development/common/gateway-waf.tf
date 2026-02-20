
module "waf_apigw" {
  source = "../../../modules/waf"

  providers = {
    aws = aws
  }

  name  = "tariff-apigw-waf-${var.environment}"
  scope = "REGIONAL"

  associate_alb = false

  ip_rate_based_rule = {
    name      = "ip-rate-limit"
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

  assets_rate_based_rule = null # not applicable to APIGW

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
  retention_in_days = 7
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
