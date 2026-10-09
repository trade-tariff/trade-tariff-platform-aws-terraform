module "notify_slack" {
  source = "../../../modules/aws-notify-slack"

  enable_sns_topic_delivery_status_logs = true

  lambda_function_name = "notify_slack_${var.environment}"
  sns_topic_name       = "slack-topic"

  slack_webhook_url = data.aws_secretsmanager_secret_version.slack_notify_lambda_slack_webhook_url.secret_string
  slack_channel     = "production-alerts"
  slack_username    = "AWS"

  lambda_description                     = "Lambda function which sends notifications to Slack"
  log_events                             = true
  cloudwatch_log_group_retention_in_days = 90
}

module "notify_slack_observability" {
  source = "../../../modules/aws-notify-slack"

  lambda_function_name = "notify_slack_observability_${var.environment}"
  sns_topic_name       = "slack-observability-topic"

  slack_webhook_url = data.aws_secretsmanager_secret_version.slack_notify_lambda_slack_webhook_url.secret_string
  slack_channel     = "production-observability"
  slack_username    = "AWS"

  lambda_description                     = "Lambda function which sends non-critical notifications to Slack"
  log_events                             = true
  cloudwatch_log_group_retention_in_days = 90
}

locals {
  alert_actions               = var.enable_sns_alerts ? [module.notify_slack.slack_topic_arn] : []
  observability_alert_actions = var.enable_sns_alerts ? [module.notify_slack_observability.slack_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_codes" {
  for_each = module.alb.target_groups

  alarm_name          = "High-5xx-errors-${each.value.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  unit                = "Count"
  threshold           = 10
  alarm_description   = "Too many HTTP 5xx errors in ${var.environment} environment for target group ${each.value.name}"
  treat_missing_data  = "notBreaching"

  alarm_actions = local.alert_actions


  dimensions = {
    LoadBalancer = module.alb.arn_suffix
    TargetGroup  = each.value.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "long_response_times" {
  # admin-https has its own alarm below because its traffic is very low.
  for_each = { for name, target_group in module.alb.target_groups : name => target_group if name != "admin-https" }

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

  alarm_actions = local.alert_actions


  dimensions = {
    LoadBalancer = module.alb.arn_suffix
    TargetGroup  = each.value.arn_suffix
  }
}

# Admin has very little traffic: half of the 5-minute windows that have any
# requests have 7 or fewer. With so few requests, one or two slow page loads
# move the average or p95 over the threshold. This alarm only uses windows with
# at least 20 requests. Every window gets a value (0 when traffic is low or
# missing), so "2 datapoints" means 10 consecutive minutes. Without the fill,
# CloudWatch skips empty windows and can join two slow requests that are far
# apart in time.
moved {
  from = aws_cloudwatch_metric_alarm.long_response_times["admin-https"]
  to   = aws_cloudwatch_metric_alarm.admin_long_response_times
}

resource "aws_cloudwatch_metric_alarm" "admin_long_response_times" {
  alarm_name          = "Long-response-times-${module.alb.target_groups["admin-https"].name}"
  alarm_description   = "Admin p95 response time is 1.5 seconds or more for 10 minutes, with at least 20 requests in each 5 minutes, in ${var.environment} for target group ${module.alb.target_groups["admin-https"].name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 1.5
  treat_missing_data  = "notBreaching"

  alarm_actions = local.alert_actions

  metric_query {
    id          = "requests"
    return_data = false

    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"
      dimensions = {
        LoadBalancer = module.alb.arn_suffix
        TargetGroup  = module.alb.target_groups["admin-https"].arn_suffix
      }
    }
  }

  metric_query {
    id          = "p95"
    return_data = false

    metric {
      metric_name = "TargetResponseTime"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "p95"
      dimensions = {
        LoadBalancer = module.alb.arn_suffix
        TargetGroup  = module.alb.target_groups["admin-https"].arn_suffix
      }
    }
  }

  metric_query {
    id          = "p95_with_traffic"
    label       = "p95 response time (seconds) when there are 20 or more requests"
    return_data = true
    expression  = "IF(FILL(requests, 0) >= 20, FILL(p95, 0), 0)"
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


  dimensions = {
    FunctionName = each.value
  }
}

#----------------------------------------------------------#
# CloudWatch alarms for the e2e scheduler dispatcher
#----------------------------------------------------------#
resource "aws_cloudwatch_metric_alarm" "e2e_scheduler_dispatcher_sustained_errors" {
  alarm_name          = "e2e-scheduler-dispatcher-sustained-errors-${var.environment}"
  alarm_description   = "trade-tariff-e2e-scheduler-production-dispatcher has errored on 3 consecutive runs (30 minutes) in ${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 600 # 10 minutes, matches expected run cadence so each period aligns to one invocation
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching" # a missing invocation is covered by the no-invocations alarm below, not this one

  dimensions = {
    FunctionName = "trade-tariff-e2e-scheduler-production-dispatcher"
  }

  alarm_actions = local.alert_actions
}

resource "aws_cloudwatch_metric_alarm" "e2e_scheduler_dispatcher_no_invocations" {
  alarm_name          = "e2e-scheduler-dispatcher-no-invocations-${var.environment}"
  alarm_description   = "trade-tariff-e2e-scheduler-production-dispatcher has not been invoked for 30 minutes (expected every 10 minutes) - EventBridge trigger may be broken"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = 600 # 10 minutes, matches expected trigger cadence
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "breaching"

  dimensions = {
    FunctionName = "trade-tariff-e2e-scheduler-production-dispatcher"
  }

  alarm_actions = local.alert_actions
}

# Monitor the slack_notify Lambda itself
resource "aws_sns_topic" "critical_email_alerts" {
  name = "critical-email-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "critical_emails" {
  topic_arn = aws_sns_topic.critical_email_alerts.arn
  protocol  = "email"
  endpoint  = "hmrc-trade-tariff-support-g@digital.hmrc.gov.uk"
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
}

#----------------------------------------------------------#
# CloudWatch alarms for GOV.UK Notify delivery failures
#----------------------------------------------------------#
resource "aws_cloudwatch_metric_alarm" "notify_delivery_failures" {
  alarm_name          = "notify-delivery-failures-${var.environment}"
  alarm_description   = "GOV.UK Notify is reporting permanent or technical delivery failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DeliveryFailures"
  namespace           = "TradeTariff/Notify"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    Environment = var.environment
  }

  alarm_actions = local.alert_actions
}

#----------------------------------------------------------#
# CloudWatch dead man's switch alarms for scheduled jobs
#----------------------------------------------------------#
locals {
  # The backend publishes the JobSuccess metric with THREE dimensions: Job,
  # Service and Environment (see ScheduledJobHeartbeat in trade-tariff-backend).
  # CloudWatch matches dimensions exactly, so an alarm must name all three or it
  # watches a metric that is never published.
  #
  # Each entry below is one (job, service) pair that genuinely publishes a
  # heartbeat. This is deliberately NOT a cross product of jobs and services: a
  # pair that never runs would have no datapoints and, with
  # treat_missing_data = "breaching", would sit in ALARM forever.
  #
  # Which service each job runs under is set by the SERVICE guards in the
  # backend's config/sidekiq.yml and by the TradeTariffBackend.uk? / .xi? guards
  # inside each worker:
  #   ImportCustomsTariffDocumentWorker     uk only
  #   ImportXiCnDocumentWorker              xi only
  #   GoodsNomenclatureReconciliationWorker uk and xi (separate cron entries)
  #   ReportWorker                          uk and xi (triggered after each
  #                                         service's CDS/TARIC sync completes)
  #   SynchronizerCheckWorker               uk and xi (every 30 minutes)
  #
  # period is the expected run interval in seconds; the alarm fires if no
  # heartbeat is seen within one interval.
  #
  # first_action is optional. When it is set, it is added to the alarm
  # description so the Slack message tells on-call what to do first.
  heartbeat_jobs = {
    "importcustomstariffdocument-uk" = {
      job     = "ImportCustomsTariffDocumentWorker"
      service = "uk"
      period  = 86400 # daily
    }
    "importxicndocument-xi" = {
      job     = "ImportXiCnDocumentWorker"
      service = "xi"
      period  = 86400 # daily
    }
    "goodsnomenclaturereconciliation-uk" = {
      job     = "GoodsNomenclatureReconciliationWorker"
      service = "uk"
      period  = 86400 # daily
    }
    "goodsnomenclaturereconciliation-xi" = {
      job     = "GoodsNomenclatureReconciliationWorker"
      service = "xi"
      period  = 86400 # daily
    }
    "report-uk" = {
      job     = "ReportWorker"
      service = "uk"
      period  = 86400 # post-sync daily
    }
    "report-xi" = {
      job     = "ReportWorker"
      service = "xi"
      period  = 86400 # post-sync daily
    }
    "synchronizercheck-uk" = {
      job          = "SynchronizerCheckWorker"
      service      = "uk"
      period       = 3600 # runs every 30 minutes; one hour allows one late run
      first_action = "Severity: Critical. Tariff staleness is not being checked, so stale tariff data will not alert. First action: check that the worker-uk ECS service is running and that Sidekiq runs SynchronizerCheckWorker, then look for errors in the CloudWatch log group for ecs/worker-uk/*. Runbook: https://transformuk.atlassian.net/wiki/x/B4AFagU"
    }
    "synchronizercheck-xi" = {
      job          = "SynchronizerCheckWorker"
      service      = "xi"
      period       = 3600 # runs every 30 minutes; one hour allows one late run
      first_action = "Severity: Critical. Tariff staleness is not being checked, so stale tariff data will not alert. First action: check that the worker-xi ECS service is running and that Sidekiq runs SynchronizerCheckWorker, then look for errors in the CloudWatch log group for ecs/worker-xi/*. Runbook: https://transformuk.atlassian.net/wiki/x/B4AFagU"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "scheduled_job_heartbeat" {
  for_each = local.heartbeat_jobs

  alarm_name          = "scheduled-job-no-heartbeat-${each.key}-${var.environment}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "JobSuccess"
  namespace           = "TradeTariff/ScheduledJobs"
  period              = each.value.period
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "breaching"

  # compact drops the empty string, so entries without first_action keep the
  # description they had before.
  alarm_description = join(". ", compact([
    "${each.value.job} (${each.value.service}) has not reported a successful completion in the expected window",
    try(each.value.first_action, ""),
  ]))

  dimensions = {
    Job         = each.value.job
    Service     = each.value.service
    Environment = var.environment
  }

  alarm_actions = local.alert_actions
}

#----------------------------------------------------------#
# CloudWatch alarms for tariff data staleness
#----------------------------------------------------------#
locals {
  # SynchronizerCheckWorker in the backend sends AgeMinutes (minutes since the
  # last applied tariff update) every 30 minutes, with the dimensions Service
  # and Environment. It sends nothing for XI on Sunday to Tuesday, because
  # TARIC does not publish on those days, so missing data is not breaching. A
  # checker that stops running is caught by the synchronizercheck-* heartbeat
  # alarms above, not by these alarms.
  tariff_staleness = {
    uk = {
      threshold   = 1600
      description = "Severity: Critical. UK tariff data in ${var.environment} has not been refreshed for more than 1600 minutes. Traders may see out-of-date tariff data. First action: check the CloudWatch log group for ecs/worker-uk/* for download_delayed, sync_run_failed or download_retry_exhausted, then check the Admin Updates page for Pending files. A download_delayed loop without errors usually means CDS has not published the file. Do not manually download or apply files unless the HMRC Tariff team tells you to. Report late files to online.tariff.feedback@hmrc.gov.uk. Runbook: https://transformuk.atlassian.net/wiki/x/B4AFagU"
    }
    xi = {
      threshold   = 2000
      description = "Severity: Critical. XI tariff data in ${var.environment} has not been refreshed for more than 2000 minutes (Sunday to Tuesday are excluded, because TARIC does not publish then). Traders on the XI service may see out-of-date tariff data. First action: check the CloudWatch log group for ecs/worker-xi/* for TARIC sync failures, then check the Admin Updates page for Pending files. Runbook: https://transformuk.atlassian.net/wiki/x/B4AFagU"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "tariff_staleness" {
  for_each = local.tariff_staleness

  alarm_name          = "tariff-staleness-${each.key}-${var.environment}"
  alarm_description   = each.value.description
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2 # two consecutive checks, so one late check does not alert
  metric_name         = "AgeMinutes"
  namespace           = "TradeTariff/TariffSync"
  period              = 1800 # matches the 30 minute checker schedule
  statistic           = "Maximum"
  threshold           = each.value.threshold
  treat_missing_data  = "notBreaching" # XI quiet days send no data; a dead checker is the heartbeat alarm's job

  dimensions = {
    Service     = each.key
    Environment = var.environment
  }

  # No ok_actions: a recovery message is informational (Notification Guidelines).
  alarm_actions = local.alert_actions
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

#----------------------------------------------------------#
# CloudWatch alarms for Sidekiq queue depth and latency
#----------------------------------------------------------#

locals {
  sidekiq_queue_depth_thresholds = {
    sync          = 10
    default       = 100
    within_1_hour = 50
    within_1_day  = 200
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_queue_depth" {
  for_each = local.sidekiq_queue_depth_thresholds

  alarm_name          = "sidekiq-queue-depth-${each.key}-${var.environment}"
  alarm_description   = "Sidekiq ${each.key} queue has more than ${each.value} jobs in ${var.environment}. Check Sidekiq Web for stuck or failing jobs: https://admin.${var.domain_name}/sidekiq/uk (UK) or https://admin.${var.domain_name}/sidekiq/xi (XI)."
  comparison_operator = "GreaterThanThreshold"
  # QueueDepth is sent every 5 minutes. 2 of 3 datapoints ignores a short
  # burst, such as the daily search index rebuild at about 05:00 UTC that adds
  # about 1,700 jobs and clears in under 5 minutes. A queue that stays full for
  # 10 minutes still alarms.
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "QueueDepth"
  namespace           = "TradeTariff/Sidekiq"
  period              = 300
  statistic           = "Maximum"
  threshold           = each.value
  treat_missing_data  = "notBreaching"

  dimensions = {
    Queue       = each.key
    Environment = var.environment
  }

  alarm_actions = local.alert_actions
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_sync_queue_latency" {
  alarm_name          = "sidekiq-sync-queue-latency-${var.environment}"
  alarm_description   = "Sidekiq sync queue has jobs waiting more than 30 minutes in ${var.environment}. CDS/TARIC sync may be stalled. Check Sidekiq Web (https://admin.${var.domain_name}/sidekiq/uk for UK, https://admin.${var.domain_name}/sidekiq/xi for XI) and worker logs."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "QueueLatency"
  namespace           = "TradeTariff/Sidekiq"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1800
  treat_missing_data  = "notBreaching"

  dimensions = {
    Queue       = "sync"
    Environment = var.environment
  }

  alarm_actions = local.alert_actions
}

#----------------------------------------------------------#
# CloudWatch alarms for Valkey clusters
#----------------------------------------------------------#

resource "aws_cloudwatch_metric_alarm" "valkey_memory_usage" {
  for_each = local.valkey

  alarm_name          = "valkey-${each.key}-high-memory-usage"
  alarm_description   = "High memory usage (>80%) on ${each.key} Valkey cluster"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.alert_actions


  metric_name = "DatabaseMemoryUsagePercentage"
  namespace   = "AWS/Elasticache"
  period      = 120
  statistic   = "Average"
  unit        = "Percent"

  dimensions = {
    ReplicationGroupId = "valkey-${each.key}-${var.environment}"
  }
}
