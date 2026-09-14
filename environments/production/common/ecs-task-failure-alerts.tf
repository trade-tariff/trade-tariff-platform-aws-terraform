#----------------------------------------------------------#
# Alerting for scheduled one-shot ECS job tasks that fail
#----------------------------------------------------------#
# Scheduled jobs (identity-job, admin-job, backend-job, dev-hub-job) run as
# one-shot ECS tasks fired by EventBridge rules, not as long-running services.
# Every existing alarm in this environment watches a SERVICE (task count, CPU,
# 5xx, response time), so a job task that exits non-zero is invisible: the task
# stops, EventBridge reports success for having launched it, and nobody is told.
#
# This wires ECS Task State Change events for those job task definitions to
# Slack.
#
# A dedicated SNS topic is used rather than the shared slack-topic because
# EventBridge needs sns:Publish granted by a resource policy, and
# aws_sns_topic_policy REPLACES a topic's policy wholesale. slack-topic
# currently has the implicit AWS default policy and carries every CloudWatch
# alarm in this account, so attaching a hand-written policy to it risks
# silently breaking all existing alerting. On a brand new topic there is
# nothing to break.

module "notify_slack_task_failures" {
  source = "../../../modules/aws-notify-slack"

  lambda_function_name = "notify_slack_task_failures_${var.environment}"
  sns_topic_name       = "slack-task-failures-topic"

  slack_webhook_url = data.aws_secretsmanager_secret_version.slack_notify_lambda_slack_webhook_url.secret_string
  slack_channel     = "production-alerts"
  slack_username    = "AWS"

  lambda_description                     = "Lambda function which sends failed ECS job task notifications to Slack"
  log_events                             = true
  cloudwatch_log_group_retention_in_days = 90
}

# EventBridge cannot publish to SNS without an explicit resource policy.
resource "aws_sns_topic_policy" "task_failures" {
  arn = module.notify_slack_task_failures.slack_topic_arn

  policy = data.aws_iam_policy_document.task_failures_topic.json
}

data "aws_iam_policy_document" "task_failures_topic" {
  statement {
    sid       = "AllowEventBridgePublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [module.notify_slack_task_failures.slack_topic_arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }

  # Preserves the account-owner access the AWS default topic policy grants, so
  # that attaching this policy does not lock the account out of its own topic.
  statement {
    sid    = "AllowAccountOwnerAccess"
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
    ]
    resources = [module.notify_slack_task_failures.slack_topic_arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [local.account_id]
    }
  }
}

locals {
  # Only the one-shot job task definitions, NOT the whole cluster. Long-running
  # service tasks stop constantly during deployments, scale-in and spot
  # reclamation, and a container that ignores SIGTERM exits 143 on a perfectly
  # normal stop. Watching the cluster would make this alarm pure noise.
  job_task_definition_families = [
    "admin-job",
    "backend-job",
    "dev-hub-job",
    "identity-job",
  ]
}

resource "aws_cloudwatch_event_rule" "ecs_job_task_failed" {
  name        = "ecs-job-task-failed-${var.environment}"
  description = "Scheduled one-shot ECS job task stopped with a non-zero container exit code"
  state       = var.enable_sns_alerts ? "ENABLED" : "DISABLED"

  event_pattern = jsonencode({
    source        = ["aws.ecs"]
    "detail-type" = ["ECS Task State Change"]
    detail = {
      lastStatus = ["STOPPED"]

      # EssentialContainerExited means the container ran and returned. It
      # excludes UserInitiated, ServiceSchedulerInitiated, SpotInterruption and
      # TaskFailedToStart, which are not job failures.
      stopCode = ["EssentialContainerExited"]

      # containers is an array; EventBridge matches if ANY element matches.
      # There is no "not equal to zero" operator, so anything-but is the way to
      # express it. Note that anything-but does not match an ABSENT field, so a
      # container that never started (image pull failure) is not caught here.
      containers = {
        exitCode = [{ "anything-but" = 0 }]
      }

      # The revision number is appended to the family, so match on prefix.
      taskDefinitionArn = [
        for family in local.job_task_definition_families :
        { prefix = "arn:aws:ecs:${var.region}:${local.account_id}:task-definition/${family}:" }
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "ecs_job_task_failed_slack" {
  rule = aws_cloudwatch_event_rule.ecs_job_task_failed.name
  arn  = module.notify_slack_task_failures.slack_topic_arn

  # The notify_slack lambda reads event["Records"][0]["Sns"]["Message"], so the
  # target must be the SNS topic and not the lambda directly. It then routes on
  # the message body: a body carrying a "text" key is passed straight through to
  # Slack, whereas an untransformed event falls through to the default formatter
  # which dumps every top-level key, including the whole multi-kilobyte detail
  # object. Hence the transformer below.
  input_transformer {
    input_paths = {
      taskdef   = "$.detail.taskDefinitionArn"
      taskarn   = "$.detail.taskArn"
      reason    = "$.detail.stoppedReason"
      startedby = "$.detail.startedBy"
    }

    input_template = <<-EOT
    {"text": ":rotating_light: *Scheduled ECS job task failed in ${var.environment}*\n*Task definition:* <taskdef>\n*Started by:* <startedby>\n*Stopped reason:* <reason>\n*Task:* <taskarn>\nCheck the `platform-logs-${var.environment}` log group for this task."}
    EOT
  }
}
