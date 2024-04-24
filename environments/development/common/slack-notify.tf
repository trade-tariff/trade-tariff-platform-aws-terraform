module "notify_slack" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/aws-notify-slack?ref=aws/aws-notify-slack-v1.0.0"

  enable_sns_topic_delivery_status_logs = true

  lambda_function_name = "notify_slack_${var.environment}"
  sns_topic_name       = "slack-topic"

  slack_webhook_url = var.slack_notify_lambda_slack_webhook_url
  slack_channel     = "trade-tariff-cloudwatch-alarms"
  slack_username    = "@here"

  lambda_description = "Lambda function which sends notifications to Slack"
  log_events         = true
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_codes" {
  alarm_name          = "High-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  unit                = "Count"
  threshold           = 10
  alarm_description   = "Too many HTTP 5xx errors in ${var.environment} environment"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

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
  threshold           = 2.5 # Development is under resource constraints
  alarm_description   = "Long response times in ${var.environment} environment"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }
}
