mock_provider "aws" {
  # The key ARN is unknown at plan. A fixed value lets the run check
  # that Performance Insights uses the key that the module creates.
  override_resource {
    target          = aws_kms_key.this
    override_during = plan
    values = {
      arn = "arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    }
  }
}

mock_provider "random" {}

variables {
  environment        = "staging"
  name               = "tariff"
  engine_version     = "16.4"
  instance_type      = "db.t4g.micro"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111"]
  secret_kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
}

run "is_off_by_default" {
  command = plan

  # performance_insights_retention_period is Optional and Computed, so the
  # null value that the module sends is unknown at plan and not asserted.
  assert {
    condition     = aws_db_instance.this.performance_insights_enabled == false
    error_message = "Performance Insights must be off by default."
  }
}

run "uses_module_kms_key_and_retention_when_enabled" {
  command = plan

  variables {
    performance_insights_enabled          = true
    performance_insights_retention_period = 93
  }

  assert {
    condition     = aws_db_instance.this.performance_insights_retention_period == 93
    error_message = "The retention period must be set when Performance Insights is enabled."
  }

  assert {
    condition     = aws_db_instance.this.performance_insights_kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    error_message = "Performance Insights must be encrypted with the KMS key that the module creates."
  }
}
