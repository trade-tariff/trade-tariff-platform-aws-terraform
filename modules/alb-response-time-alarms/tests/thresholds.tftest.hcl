mock_provider "aws" {}

run "admin_override_does_not_change_other_target_groups" {
  command = plan

  variables {
    environment              = "production"
    load_balancer_arn_suffix = "app/trade-tariff-alb-production/abc123"
    alarm_actions            = ["arn:aws:sns:eu-west-2:123456789012:slack-topic"]
    default_threshold        = 1.5
    thresholds = {
      admin-https = 5
    }
    target_groups = {
      admin-https = {
        name       = "admin-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/admin-https/1"
        arn_suffix = "targetgroup/admin-https/1"
      }
      frontend-https = {
        name       = "frontend-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/frontend-https/2"
        arn_suffix = "targetgroup/frontend-https/2"
      }
      backend-uk-https = {
        name       = "backend-uk-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/backend-uk-https/3"
        arn_suffix = "targetgroup/backend-uk-https/3"
      }
      backend-xi-https = {
        name       = "backend-xi-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/backend-xi-https/4"
        arn_suffix = "targetgroup/backend-xi-https/4"
      }
      identity-https = {
        name       = "identity-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/identity-https/5"
        arn_suffix = "targetgroup/identity-https/5"
      }
      hub-https = {
        name       = "hub-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/hub-https/6"
        arn_suffix = "targetgroup/hub-https/6"
      }
      mcp-https = {
        name       = "mcp-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/mcp-https/7"
        arn_suffix = "targetgroup/mcp-https/7"
      }
      ai-eval-https = {
        name       = "ai-eval-https"
        arn        = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:targetgroup/ai-eval-https/8"
        arn_suffix = "targetgroup/ai-eval-https/8"
      }
    }
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.long_response_times["admin-https"].threshold == 5
    error_message = "admin-https must use the configured five-second threshold"
  }

  assert {
    condition = alltrue([
      for name, alarm in aws_cloudwatch_metric_alarm.long_response_times :
      name == "admin-https" || alarm.threshold == 1.5
    ])
    error_message = "target groups without a thresholds override must keep the default 1.5-second threshold"
  }

  assert {
    condition = alltrue([
      for alarm in aws_cloudwatch_metric_alarm.long_response_times : (
        alarm.comparison_operator == "GreaterThanOrEqualToThreshold" &&
        alarm.period == 300 &&
        alarm.evaluation_periods == 2 &&
        alarm.statistic == "Average" &&
        alarm.unit == "Seconds" &&
        alarm.treat_missing_data == "notBreaching"
      )
    ])
    error_message = "response-time alarms must keep the existing evaluation policy"
  }

  assert {
    condition = alltrue([
      for alarm in aws_cloudwatch_metric_alarm.long_response_times :
      alarm.alarm_actions == toset(var.alarm_actions)
    ])
    error_message = "response-time alarms must keep the supplied notification actions"
  }
}
