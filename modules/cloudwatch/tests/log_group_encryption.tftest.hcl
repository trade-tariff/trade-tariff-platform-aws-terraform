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

  override_resource {
    target          = aws_kms_key.this
    override_during = plan
    values = {
      arn = "arn:aws:kms:eu-west-2:123456789012:key/11111111-2222-3333-4444-555555555555"
    }
  }
}

variables {
  name              = "backend-uk"
  retention_in_days = 30
}

run "encrypts_log_group_with_its_own_kms_key" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/11111111-2222-3333-4444-555555555555"
    error_message = "The log group must be encrypted with the KMS key that the module creates."
  }

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == true
    error_message = "The KMS key must have key rotation enabled."
  }

  assert {
    condition     = aws_kms_alias.this.name == "alias/cloudwatch-backend-uk"
    error_message = "The KMS alias must be named alias/cloudwatch-<name>."
  }
}

run "tags_log_group_for_export_to_s3" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.tags["ExportToS3"] == "true"
    error_message = "The log group must have the ExportToS3 = true tag so the log exporter picks it up."
  }
}

run "key_policy_lets_only_this_log_group_use_the_key" {
  command = plan

  assert {
    condition     = jsondecode(aws_kms_key_policy.this.policy).Statement[0].Principal.AWS == "arn:aws:iam::123456789012:root"
    error_message = "The first key policy statement must give the account root full access to the key."
  }

  assert {
    condition     = jsondecode(aws_kms_key_policy.this.policy).Statement[1].Principal.Service == "logs.eu-west-2.amazonaws.com"
    error_message = "The second key policy statement must allow the CloudWatch Logs service in the current region."
  }

  assert {
    condition     = jsondecode(aws_kms_key_policy.this.policy).Statement[1].Condition.ArnEquals["kms:EncryptionContext:aws:logs:arn"] == "arn:aws:logs:eu-west-2:123456789012:log-group:backend-uk"
    error_message = "The CloudWatch Logs statement must be limited to the log group that the module creates."
  }
}
