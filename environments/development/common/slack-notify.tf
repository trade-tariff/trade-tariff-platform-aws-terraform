module "notify_slack" {
  source = "../../../modules/aws-notify-slack"

  enable_sns_topic_delivery_status_logs = true

  lambda_function_name = "notify_slack_${var.environment}"
  sns_topic_name       = "slack-topic"

  slack_webhook_url = data.aws_secretsmanager_secret_version.slack_notify_lambda_slack_webhook_url.secret_string
  slack_channel     = "non-production-alerts"
  slack_username    = "AWS"

  lambda_description                     = "Lambda function which sends notifications to Slack"
  log_events                             = true
  cloudwatch_log_group_retention_in_days = 30
}

locals {
  alert_actions = var.enable_sns_alerts ? [module.notify_slack.slack_topic_arn] : []
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

  alarm_actions = local.alert_actions
  ok_actions    = local.alert_actions

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
  threshold           = 2.5 # Development is under resource constraints
  alarm_description   = "Long response times in ${var.environment} environment for target group ${each.value.name}"
  treat_missing_data  = "notBreaching"

  alarm_actions = local.alert_actions
  ok_actions    = local.alert_actions

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
    TargetGroup  = each.value.arn
  }
}

data "aws_secretsmanager_secret_version" "slack_notify_lambda_slack_webhook_url" {
  secret_id = module.slack_notify_lambda_slack_webhook_url.secret_arn
}

#----------------------------------------------------------#
# CloudWatch alarms for Lambda functions
#----------------------------------------------------------#
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

  alarm_actions = local.alert_actions
  ok_actions    = local.alert_actions

  dimensions = {
    FunctionName = each.value
  }
}

# Monitor the slack_notify Lambda itself
resource "aws_sns_topic" "critical_email_alerts" {
  name = "critical-email-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "critical_emails" {
  topic_arn = aws_sns_topic.critical_email_alerts.arn
  protocol  = "email"
  endpoint  = "alerts@dev.trade-tariff.service.gov.uk"
}

resource "aws_cloudwatch_metric_alarm" "slack_notify_self_monitor" {
  alarm_name          = "slack-notify-${var.environment}-errors"
  alarm_description   = "CRITICAL: The slack_notify Lambda itself is failing"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    FunctionName = "notify_slack_${var.environment}"
  }

  alarm_actions = var.enable_sns_alerts ? [aws_sns_topic.critical_email_alerts.arn] : []
  ok_actions    = var.enable_sns_alerts ? [aws_sns_topic.critical_email_alerts.arn] : []
}

#----------------------------------------------------------#
# CloudWatch alarms for API Gateway
#----------------------------------------------------------#
resource "aws_cloudwatch_metric_alarm" "apigw_5xx_error_rate" {
  alarm_name          = "High-5xx-errors-${module.gateway.rest_api_name}"
  alarm_description   = "API Gateway 5xx error rate > 5% for 5 minutes in ${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  threshold           = 5
  datapoints_to_alarm = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alert_actions
  ok_actions          = local.alert_actions

  metric_query {
    id          = "errors"
    return_data = false

    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"
      dimensions = {
        ApiName = module.gateway.rest_api_name
        Stage   = module.gateway.stage_name
      }
    }
  }

  metric_query {
    id          = "requests"
    return_data = false

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"
      dimensions = {
        ApiName = module.gateway.rest_api_name
        Stage   = module.gateway.stage_name
      }
    }
  }

  metric_query {
    id          = "error_rate"
    label       = "5xx Error Rate (%)"
    return_data = true
    expression  = "(errors / requests) * 100"
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_p99_latency" {
  alarm_name          = "p99-latency-${module.gateway.rest_api_name}"
  alarm_description   = "P99 latency > 5 seconds for 5 minutes in ${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 5000 # 5 seconds in ms
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alert_actions
  ok_actions          = local.alert_actions

  metric_name        = "Latency"
  namespace          = "AWS/ApiGateway"
  period             = 60
  extended_statistic = "p99"
  unit               = "Milliseconds"

  dimensions = {
    ApiName = module.gateway.rest_api_name
    Stage   = module.gateway.stage_name
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_cache_hit_ratio" {
  count               = var.environment == "production" ? 1 : 0
  alarm_name          = "cache-hit-ratio-${module.gateway.rest_api_name}"
  alarm_description   = "Cache hit ratio < 50% for 15 minutes"
  comparison_operator = "LessThanThreshold"
  threshold           = 50
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  treat_missing_data  = "breaching"
  alarm_actions       = local.alert_actions
  ok_actions          = local.alert_actions

  metric_query {
    id = "hits"

    metric {
      namespace   = "AWS/ApiGateway"
      metric_name = "CacheHitCount"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ApiName = module.gateway.rest_api_name
        Stage   = module.gateway.stage_name
      }
    }
  }

  metric_query {
    id = "misses"

    metric {
      namespace   = "AWS/ApiGateway"
      metric_name = "CacheMissCount"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ApiName = module.gateway.rest_api_name
        Stage   = module.gateway.stage_name
      }
    }
  }

  metric_query {
    id          = "hit_ratio"
    expression  = "(hits / (hits + misses)) * 100"
    label       = "Cache Hit Ratio"
    return_data = true
  }
}
