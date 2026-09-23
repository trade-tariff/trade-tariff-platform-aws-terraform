mock_provider "archive" {}

mock_provider "aws" {
  override_data {
    target = data.aws_caller_identity.current
    values = {
      account_id = "123456789012"
    }
  }

  override_data {
    target = data.aws_region.current
    values = {
      region = "eu-west-2"
    }
  }
}

variables {
  environment                   = "staging"
  cloudwatch_logs_export_bucket = "trade-tariff-logs-staging"
}

run "names_resources_after_environment" {
  command = plan

  assert {
    condition     = aws_lambda_function.log_exporter.function_name == "log-exporter-staging"
    error_message = "The Lambda function must be named log-exporter-<environment>."
  }

  assert {
    condition     = aws_iam_role.log_exporter.name == "log-exporter-staging"
    error_message = "The IAM role must be named log-exporter-<environment>."
  }

  assert {
    condition     = aws_cloudwatch_event_rule.log_exporter.name == "log-exporter-staging"
    error_message = "The EventBridge rule must be named log-exporter-<environment>."
  }
}

run "lambda_log_group_matches_function_name" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.log_exporter.name == "/aws/lambda/log-exporter-staging"
    error_message = "The log group must be /aws/lambda/<function name> so the Lambda writes to it."
  }

  assert {
    condition     = aws_cloudwatch_log_group.log_exporter.retention_in_days == 14
    error_message = "The log group must keep logs for 14 days by default."
  }
}

run "lambda_gets_bucket_and_account_from_module" {
  command = plan

  assert {
    condition     = aws_lambda_function.log_exporter.environment[0].variables["S3_BUCKET"] == "trade-tariff-logs-staging"
    error_message = "The Lambda S3_BUCKET variable must be the export bucket."
  }

  assert {
    condition     = aws_lambda_function.log_exporter.environment[0].variables["AWS_ACCOUNT"] == "123456789012"
    error_message = "The Lambda AWS_ACCOUNT variable must be the current account id."
  }
}

run "runs_every_four_hours_from_eventbridge" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.log_exporter.schedule_expression == "rate(4 hours)"
    error_message = "The EventBridge rule must fire every 4 hours."
  }

  assert {
    condition     = aws_lambda_permission.log_exporter.principal == "events.amazonaws.com"
    error_message = "Only EventBridge must be allowed to invoke the Lambda."
  }
}

run "role_can_only_be_assumed_by_lambda" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.log_exporter.assume_role_policy).Statement[0].Principal.Service == "lambda.amazonaws.com"
    error_message = "Only the Lambda service must be able to assume the role."
  }
}

run "role_policy_limits_ssm_logs_and_s3_resources" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role_policy.log_exporter.policy).Statement[1].Resource == "arn:aws:ssm:eu-west-2:123456789012:parameter/log-exporter-last-export/*"
    error_message = "SSM access must be limited to the log-exporter-last-export parameters in this account and region."
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.log_exporter.policy).Statement[2].Resource == "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/lambda/log-exporter-*"
    error_message = "Log write access must be limited to the log-exporter Lambda log groups."
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.log_exporter.policy).Statement[3].Resource == "arn:aws:s3:::trade-tariff-logs-staging/*"
    error_message = "S3 object access must be limited to objects in the export bucket."
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.log_exporter.policy).Statement[4].Resource == "arn:aws:s3:::trade-tariff-logs-staging"
    error_message = "S3 bucket ACL access must be limited to the export bucket."
  }
}
