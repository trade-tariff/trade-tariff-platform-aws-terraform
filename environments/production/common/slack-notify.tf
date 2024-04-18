data "aws_secretsmanager_secret_version" "slack" {
  secret_id = "slack"
}

locals {
  slack = jsondecode(
    data.aws_secretsmanager_secret_version.slack.secret_string
  )
}

module "notify_slack" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/aws-notify-slack?ref=aws/aws-notify-slack-v1.0.0"

  for_each = toset([
    "production"
  ])

  enable_sns_topic_delivery_status_logs = true

  lambda_function_name = "notify_slack_${each.value}"
  sns_topic_name       = "slack-topic"

  slack_webhook_url = local.slack.webhook_url
  slack_channel     = "trade-tariff-cloudwatch-alarms"
  slack_username    = "@here"

  lambda_description = "Lambda function which sends notifications to Slack"
  log_events         = true

  tags = {
    Name = "cloudwatch-alerts-to-slack"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_codes" {
  alarm_name          = "High-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  unit                = "Count"
  threshold           = 2
  alarm_description   = "Too many HTTP 5xx errors"
  treat_missing_data  = "missing"

  alarm_actions = [module.notify_slack["production"].slack_topic_arn]
  ok_actions    = [module.notify_slack["production"].slack_topic_arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_4xx_codes" {
  alarm_name          = "High-4xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Sum"
  unit                = "Count"
  threshold           = 3
  alarm_description   = "Too many HTTP 4xx errors"
  treat_missing_data  = "missing"

  alarm_actions = [module.notify_slack["production"].slack_topic_arn]
  ok_actions    = [module.notify_slack["production"].slack_topic_arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_connections_refused" {
  alarm_name          = "High-connections-refused"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "RejectedConnectionCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  unit                = "Count"
  threshold           = 2
  alarm_description   = "Too many connection refused errors"
  treat_missing_data  = "missing"

  alarm_actions = [module.notify_slack["production"].slack_topic_arn]
  ok_actions    = [module.notify_slack["production"].slack_topic_arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "long_response_times" {
  alarm_name          = "Long-response-times"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  unit                = "Seconds"
  threshold           = 0.6
  alarm_description   = "Long response times"
  treat_missing_data  = "missing"

  alarm_actions = [module.notify_slack["production"].slack_topic_arn]
  ok_actions    = [module.notify_slack["production"].slack_topic_arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }
}

resource "aws_route53_health_check" "dns_health_check" {
  fqdn              = "trade-tariff.service.gov.uk"
  port              = 443
  type              = "HTTPS"
  measure_latency   = true
  request_interval  = 30
  failure_threshold = 3
}

resource "aws_cloudwatch_metric_alarm" "dns_alarm" {
  alarm_name                = "dns-health-check-failed"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthCheckStatus"
  namespace                 = "AWS/Route53"
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = "1"
  treat_missing_data        = "missing"
  insufficient_data_actions = []

  alarm_actions     = [module.notify_slack["production"].slack_topic_arn]
  ok_actions        = [module.notify_slack["production"].slack_topic_arn]
  alarm_description = "DNS resolution failed, so environment is down"

  dimensions = {
    HealthCheckId = aws_route53_health_check.dns_health_check.id
  }
}
