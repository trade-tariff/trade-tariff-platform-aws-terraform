mock_provider "aws" {
  # The policy is built from the log group ARN, which is unknown at plan.
  # A fixed ARN makes the policy JSON known so the run can decode it.
  override_resource {
    target          = aws_cloudwatch_log_group.firehose_log_group
    override_during = plan
    values = {
      arn = "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/kinesisfirehose/cloudwatch-to-newrelic"
    }
  }
}

variables {
  environment             = "staging"
  newrelic_license_key    = "test-licence-key"
  firehose_backups_bucket = "arn:aws:s3:::test-firehose-backups"
}

run "role_can_only_be_assumed_by_firehose" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.firehose_role.assume_role_policy).Statement[0].Principal.Service == "firehose.amazonaws.com"
    error_message = "Only the Firehose service must be able to assume the role."
  }
}

run "policy_limits_s3_access_to_the_backup_bucket" {
  command = plan

  assert {
    condition = jsondecode(aws_iam_role_policy.firehose_policy.policy).Statement[0].Resource == [
      "arn:aws:s3:::test-firehose-backups",
      "arn:aws:s3:::test-firehose-backups/*",
    ]
    error_message = "S3 access must be limited to the backup bucket and its objects."
  }
}

run "policy_limits_log_access_to_the_firehose_log_group" {
  command = plan

  assert {
    condition = jsondecode(aws_iam_role_policy.firehose_policy.policy).Statement[1].Resource == [
      "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/kinesisfirehose/cloudwatch-to-newrelic",
      "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/kinesisfirehose/cloudwatch-to-newrelic:*",
    ]
    error_message = "Log access must be limited to the Firehose log group and its streams."
  }
}
