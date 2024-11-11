module "waf" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/waf?ref=aws/waf-v1.2.3"

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
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name = "aws-waf-logs-tariff-${var.environment}"
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = module.waf.web_acl_id

  logging_filter {
    default_behavior = "DROP"
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
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
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
