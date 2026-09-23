mock_provider "aws" {
  override_resource {
    target          = aws_iam_role.sns_feedback_role
    override_during = plan
    values = {
      arn = "arn:aws:iam::123456789012:role/sns-feedback"
    }
  }
}

mock_provider "local" {}

mock_provider "null" {}

# The lambda module runs package.py through the external provider to plan
# the zip file. The mock must return the keys that the lambda module reads.
mock_provider "external" {
  override_data {
    target = module.lambda.data.external.archive_prepare
    values = {
      result = {
        filename            = "builds/notify_slack.zip"
        build_plan          = "{}"
        build_plan_filename = "builds/notify_slack.plan.json"
        timestamp           = "0"
        was_missing         = "false"
      }
    }
  }
}

variables {
  sns_topic_name    = "slack-alerts"
  slack_webhook_url = "https://hooks.slack.com/services/T000/B000/XXXX"
  slack_channel     = "trade-tariff-alerts"
  slack_username    = "aws-alerts"
}

run "creates_topic_and_subscription_by_default" {
  command = plan

  assert {
    condition     = length(aws_sns_topic.this) == 1
    error_message = "One SNS topic must be created by default."
  }

  assert {
    condition     = aws_sns_topic.this[0].name == "slack-alerts"
    error_message = "The SNS topic must use sns_topic_name."
  }

  assert {
    condition     = length(aws_sns_topic_subscription.sns_notify_slack) == 1
    error_message = "One Lambda subscription must be created by default."
  }

  assert {
    condition     = aws_sns_topic_subscription.sns_notify_slack[0].protocol == "lambda"
    error_message = "The subscription must deliver messages to the Lambda."
  }
}

run "encrypts_topic_with_given_kms_key" {
  command = plan

  variables {
    sns_topic_kms_key_id = "arn:aws:kms:eu-west-2:123456789012:key/11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = aws_sns_topic.this[0].kms_master_key_id == "arn:aws:kms:eu-west-2:123456789012:key/11111111-2222-3333-4444-555555555555"
    error_message = "The SNS topic must be encrypted with sns_topic_kms_key_id."
  }
}

run "creates_nothing_when_create_is_false" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = length(aws_sns_topic.this) == 0
    error_message = "No SNS topic must be created when create is false."
  }

  assert {
    condition     = length(aws_sns_topic_subscription.sns_notify_slack) == 0
    error_message = "No subscription must be created when create is false."
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.lambda) == 0
    error_message = "No log group must be created when create is false."
  }

  assert {
    condition     = length(data.aws_iam_policy_document.lambda) == 0
    error_message = "No Lambda policy document must be built when create is false."
  }

  assert {
    condition     = length(aws_iam_role.sns_feedback_role) == 0
    error_message = "No SNS feedback role must be created when create is false."
  }

  assert {
    condition     = output.slack_topic_arn == ""
    error_message = "The slack_topic_arn output must be empty when create is false."
  }
}

run "skips_topic_when_create_sns_topic_is_false" {
  command = plan

  variables {
    create_sns_topic = false
  }

  assert {
    condition     = length(aws_sns_topic.this) == 0
    error_message = "No SNS topic must be created when create_sns_topic is false."
  }
}

run "sends_no_delivery_logs_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role.sns_feedback_role) == 0
    error_message = "No SNS feedback role must be created when delivery status logs are disabled."
  }

  assert {
    condition     = aws_sns_topic.this[0].lambda_failure_feedback_role_arn == null
    error_message = "The topic must have no failure feedback role when delivery status logs are disabled."
  }

  assert {
    condition     = aws_sns_topic.this[0].lambda_success_feedback_sample_rate == null
    error_message = "The topic must have no success sample rate when delivery status logs are disabled."
  }
}

run "creates_feedback_role_for_delivery_logs" {
  command = plan

  variables {
    enable_sns_topic_delivery_status_logs = true
    sns_topic_feedback_role_name          = "sns-feedback"
  }

  assert {
    condition     = length(aws_iam_role.sns_feedback_role) == 1
    error_message = "One SNS feedback role must be created when delivery status logs are enabled and no role is given."
  }

  assert {
    condition     = jsondecode(aws_iam_role.sns_feedback_role[0].assume_role_policy).Statement[0].Principal.Service == "sns.amazonaws.com"
    error_message = "Only SNS must be able to assume the feedback role."
  }

  assert {
    condition     = aws_sns_topic.this[0].lambda_failure_feedback_role_arn == "arn:aws:iam::123456789012:role/sns-feedback"
    error_message = "The topic failure feedback role must be the role that the module creates."
  }

  assert {
    condition     = aws_sns_topic.this[0].lambda_success_feedback_role_arn == "arn:aws:iam::123456789012:role/sns-feedback"
    error_message = "The topic success feedback role must be the role that the module creates."
  }

  assert {
    condition     = aws_sns_topic.this[0].lambda_success_feedback_sample_rate == 100
    error_message = "The topic must log 100 percent of successful deliveries by default."
  }

  assert {
    condition     = output.sns_topic_feedback_role_arn == "arn:aws:iam::123456789012:role/sns-feedback"
    error_message = "The sns_topic_feedback_role_arn output must be the role that the module creates."
  }
}

run "uses_given_feedback_role_for_delivery_logs" {
  command = plan

  variables {
    enable_sns_topic_delivery_status_logs = true
    sns_topic_lambda_feedback_role_arn    = "arn:aws:iam::123456789012:role/existing-feedback"
  }

  assert {
    condition     = length(aws_iam_role.sns_feedback_role) == 0
    error_message = "No SNS feedback role must be created when sns_topic_lambda_feedback_role_arn is given."
  }

  assert {
    condition     = aws_sns_topic.this[0].lambda_failure_feedback_role_arn == "arn:aws:iam::123456789012:role/existing-feedback"
    error_message = "The topic failure feedback role must be the role that the caller gives."
  }
}
