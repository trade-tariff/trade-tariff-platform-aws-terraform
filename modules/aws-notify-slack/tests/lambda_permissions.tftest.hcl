mock_provider "aws" {
  # AWS returns log group ARNs that end in ":*". The module must not add a
  # second ":*" when it builds the IAM resource from this ARN.
  override_resource {
    target          = aws_cloudwatch_log_group.lambda
    override_during = plan
    values = {
      arn = "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/lambda/slack-notifier:*"
    }
  }

  # The mock returns a random string for json. The lambda module sends it to
  # an IAM role policy, and the provider rejects a policy that is not JSON.
  # The statement blocks are still built from the module configuration.
  override_data {
    target = data.aws_iam_policy_document.lambda
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
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
  sns_topic_name       = "slack-alerts"
  slack_webhook_url    = "https://hooks.slack.com/services/T000/B000/XXXX"
  slack_channel        = "trade-tariff-alerts"
  slack_username       = "aws-alerts"
  lambda_function_name = "slack-notifier"
}

run "names_log_group_after_lambda_function" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.lambda[0].name == "/aws/lambda/slack-notifier"
    error_message = "The log group must be /aws/lambda/<lambda_function_name> so the Lambda writes to it."
  }
}

run "lambda_can_only_write_to_its_own_log_group" {
  command = plan

  assert {
    condition     = length(data.aws_iam_policy_document.lambda[0].statement) == 1
    error_message = "The Lambda policy must have only the CloudWatch Logs statement when no KMS key is given."
  }

  assert {
    condition     = data.aws_iam_policy_document.lambda[0].statement[0].actions == toset(["logs:CreateLogStream", "logs:PutLogEvents"])
    error_message = "The Lambda must only be allowed to create log streams and put log events."
  }

  assert {
    condition     = data.aws_iam_policy_document.lambda[0].statement[0].resources == toset(["arn:aws:logs:eu-west-2:123456789012:log-group:/aws/lambda/slack-notifier:*"])
    error_message = "The CloudWatch Logs statement must be limited to the Lambda log group, with one ':*' suffix."
  }
}

run "lambda_can_decrypt_with_given_kms_key" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.lambda[0].statement) == 2
    error_message = "The Lambda policy must have a KMS statement when kms_key_arn is given."
  }

  assert {
    condition     = data.aws_iam_policy_document.lambda[0].statement[1].actions == toset(["kms:Decrypt"])
    error_message = "The KMS statement must only allow kms:Decrypt."
  }

  assert {
    condition     = data.aws_iam_policy_document.lambda[0].statement[1].resources == toset(["arn:aws:kms:eu-west-2:123456789012:key/11111111-2222-3333-4444-555555555555"])
    error_message = "The KMS statement must be limited to kms_key_arn."
  }
}

run "creates_lambda_role_with_prefixed_name" {
  command = plan

  assert {
    condition     = output.lambda_iam_role_name == "lambda-slack-notifier"
    error_message = "The Lambda role must be named <iam_role_name_prefix>-<lambda_function_name>."
  }
}

run "uses_given_lambda_role" {
  command = plan

  variables {
    lambda_role = "arn:aws:iam::123456789012:role/existing-lambda-role"
  }

  assert {
    condition     = output.lambda_iam_role_name == ""
    error_message = "No Lambda role must be created when lambda_role is given."
  }
}
