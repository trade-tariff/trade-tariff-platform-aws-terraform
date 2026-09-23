mock_provider "aws" {
  # The key ARN is unknown at plan. A fixed value lets the runs check
  # which key the cluster uses.
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
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = "16.4"
  username                        = "tariff_admin"
  cluster_name                    = "tariff-cluster"
  instance_class                  = "db.serverless"
  database_name                   = "tariff"
  private_subnet_ids              = ["subnet-00000000000000000", "subnet-11111111111111111"]
  db_cluster_parameter_group_name = "default.aurora-postgresql16"
}

run "does_not_encrypt_or_create_a_key_when_encryption_is_disabled" {
  command = plan

  variables {
    encryption_at_rest = false
  }

  assert {
    condition     = aws_rds_cluster.this.storage_encrypted == false
    error_message = "storage_encrypted must be false when encryption_at_rest is false."
  }

  assert {
    condition     = length(aws_kms_key.this) == 0
    error_message = "No KMS key must be created when encryption at rest is off."
  }
}

run "creates_a_rotating_key_when_encrypted_without_a_key" {
  command = plan

  variables {
    encryption_at_rest = true
  }

  assert {
    condition     = aws_rds_cluster.this.storage_encrypted == true
    error_message = "Storage must be encrypted when encryption_at_rest is true."
  }

  assert {
    condition     = length(aws_kms_key.this) == 1
    error_message = "A KMS key must be created when encryption is on and no key is given."
  }

  assert {
    condition     = aws_kms_key.this[0].enable_key_rotation == true
    error_message = "The module KMS key must rotate."
  }

  assert {
    condition     = aws_rds_cluster.this.kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    error_message = "The cluster must be encrypted with the KMS key that the module creates."
  }
}

run "uses_the_caller_key_when_encrypted_with_a_key" {
  command = plan

  variables {
    encryption_at_rest = true
    kms_key_id         = "arn:aws:kms:eu-west-2:123456789012:key/22222222-2222-2222-2222-222222222222"
  }

  assert {
    condition     = length(aws_kms_key.this) == 0
    error_message = "No KMS key must be created when the caller gives one."
  }

  assert {
    condition     = aws_rds_cluster.this.kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/22222222-2222-2222-2222-222222222222"
    error_message = "The cluster must be encrypted with the KMS key that the caller gives."
  }
}

run "performance_insights_uses_the_module_key" {
  command = plan

  variables {
    encryption_at_rest                    = true
    performance_insights_enabled          = true
    performance_insights_retention_period = 31
  }

  assert {
    condition     = aws_rds_cluster.this.performance_insights_kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    error_message = "Performance Insights must use the KMS key that the module creates."
  }

  assert {
    condition     = aws_rds_cluster.this.performance_insights_retention_period == 31
    error_message = "The retention period must be set when Performance Insights is enabled."
  }
}

run "performance_insights_uses_the_caller_key" {
  command = plan

  variables {
    encryption_at_rest           = true
    kms_key_id                   = "arn:aws:kms:eu-west-2:123456789012:key/22222222-2222-2222-2222-222222222222"
    performance_insights_enabled = true
  }

  assert {
    condition     = aws_rds_cluster.this.performance_insights_kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/22222222-2222-2222-2222-222222222222"
    error_message = "Performance Insights must use the KMS key that the caller gives."
  }
}
