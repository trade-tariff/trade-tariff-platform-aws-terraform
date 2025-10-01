module "notify_slack" {
  source = "../../../modules/aws-notify-slack"

  enable_sns_topic_delivery_status_logs = true

  lambda_function_name = "notify_slack_${var.environment}"
  sns_topic_name       = "slack-topic"

  slack_webhook_url = data.aws_secretsmanager_secret_version.slack_notify_lambda_slack_webhook_url.secret_string
  slack_channel     = "non-production-alerts"
  slack_username    = "AWS"

  lambda_description = "Lambda function which sends notifications to Slack"
  log_events         = true
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_codes" {
  for_each = module.alb.target_groups

  alarm_name          = "High-5xx-errors-${each.value.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  unit                = "Count"
  threshold           = 10
  alarm_description   = "Too many HTTP 5xx errors in ${var.environment} environment for target group ${each.value.name}"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
    TargetGroup  = each.value.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "long_response_times" {
  for_each = module.alb.target_groups

  alarm_name          = "Long-response-times-${each.value.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  unit                = "Seconds"
  threshold           = 1.5
  alarm_description   = "Long response times in ${var.environment} environment for target group ${each.value.name}"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
    TargetGroup  = each.value.arn
  }
}

data "aws_secretsmanager_secret_version" "slack_notify_lambda_slack_webhook_url" {
  secret_id = module.slack_notify_lambda_slack_webhook_url.secret_arn
}

resource "aws_cloudwatch_metric_alarm" "lambds_errors" {
  for_each = local.monitored_lambdas

  alarm_name          = "Lambda-errors-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300" # 5 minutes
  statistic           = "Sum"
  unit                = "Count"
  threshold           = 0
  alarm_description   = "Lambda function ${each.key} is experiencing errors in ${var.environment}"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  dimensions = {
    FunctionName = each.value
  }
}
