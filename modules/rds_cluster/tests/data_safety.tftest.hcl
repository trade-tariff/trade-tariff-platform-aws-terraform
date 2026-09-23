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
  engine_mode                     = "provisioned"
  engine_version                  = "16.4"
  username                        = "tariff_admin"
  cluster_name                    = "tariff-cluster"
  cluster_instances               = 1
  instance_class                  = "db.serverless"
  database_name                   = "tariff"
  private_subnet_ids              = ["subnet-00000000000000000", "subnet-11111111111111111"]
  db_cluster_parameter_group_name = "default.aurora-postgresql16"
}

run "protects_from_deletion_by_default" {
  command = plan

  assert {
    condition     = aws_rds_cluster.this.deletion_protection == true
    error_message = "Deletion protection must be on by default."
  }
}

run "takes_a_named_final_snapshot" {
  command = plan

  assert {
    condition     = aws_rds_cluster.this.skip_final_snapshot == false
    error_message = "A final snapshot must always be taken when the cluster is deleted."
  }

  assert {
    condition     = aws_rds_cluster.this.final_snapshot_identifier == "tariff-cluster-final-a1b2"
    error_message = "The final snapshot must be named <cluster_name>-final-<random hex>."
  }

  assert {
    condition     = aws_rds_cluster.this.copy_tags_to_snapshot == true
    error_message = "Tags must be copied to snapshots."
  }
}

run "keeps_backups_for_seven_days_by_default" {
  command = plan

  assert {
    condition     = aws_rds_cluster.this.backup_retention_period == 7
    error_message = "Backups must be kept for 7 days by default."
  }
}

run "uses_iam_auth" {
  command = plan

  assert {
    condition     = aws_rds_cluster.this.iam_database_authentication_enabled == true
    error_message = "IAM database authentication must be enabled."
  }
}

run "applies_changes_in_the_maintenance_window_by_default" {
  command = plan

  assert {
    condition     = aws_rds_cluster.this.apply_immediately == false
    error_message = "Cluster changes must wait for the maintenance window by default."
  }

  assert {
    condition     = aws_rds_cluster_instance.this[0].apply_immediately == false
    error_message = "Instance changes must always wait for the maintenance window."
  }
}
