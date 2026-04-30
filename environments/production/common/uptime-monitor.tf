locals {
  # Add URLs to monitor here. The key becomes the Endpoint dimension in CloudWatch
  # and must be unique. Example:
  #   "search-suggestions" = "https://www.trade-tariff.service.gov.uk/api/v2/search_suggestions"
  uptime_endpoints = {
    "find-commodity" = "https://www.trade-tariff.service.gov.uk/find_commodity"
  }

  # Number of consecutive 1-minute failures before PagerDuty is alerted
  uptime_failure_threshold = 3
}

# ---------------------------------------------------------------------------
# Lambda: URL checker
# Runs every minute via EventBridge, probes each URL, emits custom metrics.
# ---------------------------------------------------------------------------

data "archive_file" "uptime_checker" {
  type        = "zip"
  source_dir  = "../../../common/lambda/trade-tariff-uptime-checker"
  output_path = "lambda_uptime_checker.zip"
}

module "uptime_checker" {
  source = "../../../modules/lambda"

  function_name    = "trade-tariff-uptime-checker-${var.environment}"
  filename         = data.archive_file.uptime_checker.output_path
  handler          = "lambda_function.lambda_handler"
  runtime          = "ruby3.4"
  source_code_hash = data.archive_file.uptime_checker.output_base64sha256
  memory_size      = 256
  timeout          = 60

  additional_policy_arns = [aws_iam_policy.uptime_checker_cloudwatch.arn]

  environment_variables = {
    MONITORED_URLS = jsonencode([
      for name, url in local.uptime_endpoints : { name = name, url = url }
    ])
  }
}

resource "aws_iam_policy" "uptime_checker_cloudwatch" {
  name = "trade-tariff-uptime-checker-cloudwatch-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "TradeTariff/Uptime"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "uptime_checker" {
  name                = "trade-tariff-uptime-checker-${var.environment}"
  description         = "Triggers uptime checker Lambda every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "uptime_checker" {
  rule = aws_cloudwatch_event_rule.uptime_checker.name
  arn  = module.uptime_checker.lambda_arn
}

resource "aws_lambda_permission" "uptime_checker_eventbridge" {
  statement_id  = "AllowEventBridgeInvokeUptimeChecker"
  action        = "lambda:InvokeFunction"
  function_name = module.uptime_checker.lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.uptime_checker.arn
}

# ---------------------------------------------------------------------------
# CloudWatch alarms — one per endpoint
# Fires after uptime_failure_threshold consecutive 1-minute failures.
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "uptime" {
  for_each = local.uptime_endpoints

  alarm_name          = "uptime-${each.key}-${var.environment}"
  alarm_description   = "Uptime check failed for ${each.value}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = local.uptime_failure_threshold
  datapoints_to_alarm = local.uptime_failure_threshold
  metric_name         = "Availability"
  namespace           = "TradeTariff/Uptime"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  treat_missing_data  = "breaching"

  dimensions = {
    Endpoint = each.key
  }

  alarm_actions = [aws_sns_topic.uptime_alerts.arn]
  ok_actions    = [aws_sns_topic.uptime_alerts.arn]
}

# ---------------------------------------------------------------------------
# SNS topic — fan-out point between alarms and the PagerDuty Lambda
# ---------------------------------------------------------------------------

resource "aws_sns_topic" "uptime_alerts" {
  name = "trade-tariff-uptime-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "uptime_pagerduty" {
  topic_arn = aws_sns_topic.uptime_alerts.arn
  protocol  = "lambda"
  endpoint  = module.uptime_pagerduty.lambda_arn
}

# ---------------------------------------------------------------------------
# Lambda: PagerDuty forwarder
# Translates CloudWatch Alarm SNS payloads into PagerDuty Events API v2 calls.
# ---------------------------------------------------------------------------

data "archive_file" "uptime_pagerduty" {
  type        = "zip"
  source_dir  = "../../../common/lambda/trade-tariff-uptime-pagerduty"
  output_path = "lambda_uptime_pagerduty.zip"
}

module "uptime_pagerduty" {
  source = "../../../modules/lambda"

  function_name    = "trade-tariff-uptime-pagerduty-${var.environment}"
  filename         = data.archive_file.uptime_pagerduty.output_path
  handler          = "lambda_function.lambda_handler"
  runtime          = "ruby3.4"
  source_code_hash = data.archive_file.uptime_pagerduty.output_base64sha256
  memory_size      = 128
  timeout          = 30

  additional_policy_arns = [aws_iam_policy.uptime_pagerduty_secrets.arn]

  environment_variables = {
    PAGERDUTY_SECRET_ARN = module.uptime_pagerduty_secret.secret_arn
  }
}

resource "aws_iam_policy" "uptime_pagerduty_secrets" {
  name = "trade-tariff-uptime-pagerduty-secrets-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = module.uptime_pagerduty_secret.secret_arn
      }
    ]
  })
}

resource "aws_lambda_permission" "uptime_pagerduty_sns" {
  statement_id  = "AllowSNSInvokeUptimePagerduty"
  action        = "lambda:InvokeFunction"
  function_name = module.uptime_pagerduty.lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.uptime_alerts.arn
}

# ---------------------------------------------------------------------------
# Secret: PagerDuty routing key
# Populate manually after apply:
#   aws secretsmanager put-secret-value \
#     --secret-id trade-tariff-uptime-pagerduty-production \
#     --secret-string '{"routing_key":"<your-integration-key>"}'
# ---------------------------------------------------------------------------

resource "aws_kms_key" "uptime_monitor" {
  description             = "KMS key for uptime monitor secrets"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "uptime_monitor" {
  name          = "alias/uptime-monitor-${var.environment}"
  target_key_id = aws_kms_key.uptime_monitor.key_id
}

module "uptime_pagerduty_secret" {
  source = "../../../modules/secret"

  name            = "trade-tariff-uptime-pagerduty-${var.environment}"
  kms_key_arn     = aws_kms_key.uptime_monitor.arn
  recovery_window = "7"
}

# ---------------------------------------------------------------------------
# CloudWatch dashboard — availability and response time per endpoint
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "uptime" {
  dashboard_name = "trade-tariff-uptime-${var.environment}"

  dashboard_body = jsonencode({
    widgets = flatten([
      for name, url in local.uptime_endpoints : [
        {
          type   = "metric"
          width  = 12
          height = 6
          properties = {
            title   = "${name} — Availability"
            region  = var.region
            metrics = [["TradeTariff/Uptime", "Availability", "Endpoint", name]]
            period  = 60
            stat    = "Minimum"
            view    = "timeSeries"
            yAxis   = { left = { min = 0, max = 1 } }
            annotations = {
              horizontal = [{ value = 1, color = "#2ca02c", label = "Up" }]
            }
          }
        },
        {
          type   = "metric"
          width  = 12
          height = 6
          properties = {
            title   = "${name} — Response Time (ms)"
            region  = var.region
            metrics = [["TradeTariff/Uptime", "ResponseTime", "Endpoint", name]]
            period  = 60
            stat    = "Average"
            view    = "timeSeries"
            yAxis   = { left = { min = 0 } }
          }
        }
      ]
    ])
  })
}
