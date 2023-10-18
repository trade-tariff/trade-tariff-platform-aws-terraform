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
    "development"
  ])

  enable_sns_topic_delivery_status_logs = true

  lambda_function_name = "notify_slack_${each.value}"
  sns_topic_name       = "slack-topic"

  slack_webhook_url = local.slack.webhook_url
  slack_channel     = "tariff-alerts"
  slack_username    = "@here"

  lambda_description = "Lambda function which sends notifications to Slack"
  log_events         = true

  tags = {
    Name = "cloudwatch-alerts-to-slack"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "Test slack notification from CW alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "2"
  alarm_description   = "Test Alarm!!!"

  alarm_actions = [module.notify_slack["development"].slack_topic_arn]
  ok_actions    = [module.notify_slack["development"].slack_topic_arn]

  dimensions = {
    FunctionName = module.notify_slack["development"].notify_slack_lambda_function_name
  }
}
