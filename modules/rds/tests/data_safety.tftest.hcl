mock_provider "aws" {}

mock_provider "random" {
  # The snapshot suffix is random and unknown at plan.
  # A fixed value lets the run check how the name is built.
  override_resource {
    target          = random_id.final_snapshot
    override_during = plan
    values = {
      hex = "a1b2"
    }
  }
}

variables {
  environment        = "staging"
  name               = "tariff"
  engine             = "postgres"
  engine_version     = "16.4"
  instance_type      = "db.t4g.micro"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111"]
  secret_kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
}

run "encrypts_storage" {
  command = plan

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "Database storage must always be encrypted."
  }
}

run "protects_from_deletion_by_default" {
  command = plan

  assert {
    condition     = aws_db_instance.this.deletion_protection == true
    error_message = "Deletion protection must be on by default."
  }
}

run "takes_a_named_final_snapshot" {
  command = plan

  assert {
    condition     = aws_db_instance.this.skip_final_snapshot == false
    error_message = "A final snapshot must always be taken when the database is deleted."
  }

  assert {
    condition     = aws_db_instance.this.final_snapshot_identifier == "tariff-final-a1b2"
    error_message = "The final snapshot must be named <name>-final-<random hex>."
  }

  assert {
    condition     = aws_db_instance.this.copy_tags_to_snapshot == true
    error_message = "Tags must be copied to snapshots."
  }
}

run "keeps_backups_for_seven_days_by_default" {
  command = plan

  assert {
    condition     = aws_db_instance.this.backup_retention_period == 7
    error_message = "Backups must be kept for 7 days by default."
  }
}

run "uses_iam_auth_and_is_not_public" {
  command = plan

  assert {
    condition     = aws_db_instance.this.iam_database_authentication_enabled == true
    error_message = "IAM database authentication must be enabled."
  }

  # The module does not set publicly_accessible, so it is null at plan and
  # AWS uses its default of false. The check fails if anyone sets it to true.
  assert {
    condition     = aws_db_instance.this.publicly_accessible != true
    error_message = "The database must not be publicly accessible."
  }
}

run "applies_changes_in_the_maintenance_window" {
  command = plan

  assert {
    condition     = aws_db_instance.this.apply_immediately == false
    error_message = "Changes must wait for the maintenance window so the server does not restart during the day."
  }
}

run "uses_its_own_rotating_kms_key" {
  command = plan

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == true
    error_message = "The module KMS key must rotate."
  }

  assert {
    condition     = aws_kms_key.this.description == "KMS key for the tariff RDS instance on staging."
    error_message = "The KMS key description must name the database and environment."
  }
}
