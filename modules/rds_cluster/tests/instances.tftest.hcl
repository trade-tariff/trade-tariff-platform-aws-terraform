mock_provider "aws" {}
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

run "creates_no_instances_by_default" {
  command = plan

  assert {
    condition     = length(aws_rds_cluster_instance.this) == 0
    error_message = "No cluster instances must be created by default."
  }
}

run "names_instances_from_the_cluster_name" {
  command = plan

  variables {
    cluster_instances = 2
  }

  assert {
    condition     = aws_rds_cluster_instance.this[*].identifier == ["tariff-cluster-0", "tariff-cluster-1"]
    error_message = "Instances must be named <cluster_name>-<index> when no identifiers are given."
  }
}

run "uses_caller_identifiers_when_given" {
  command = plan

  variables {
    cluster_instances    = 2
    instance_identifiers = ["tariff-writer", "tariff-reader"]
  }

  assert {
    condition     = aws_rds_cluster_instance.this[*].identifier == ["tariff-writer", "tariff-reader"]
    error_message = "Instances must use the identifiers that the caller gives, in order."
  }
}

run "sets_serverless_scaling_for_provisioned_mode" {
  command = plan

  variables {
    min_capacity = 0.5
    max_capacity = 16
  }

  assert {
    condition     = length(aws_rds_cluster.this.serverlessv2_scaling_configuration) == 1
    error_message = "Serverless v2 scaling must be set when engine_mode is provisioned."
  }

  assert {
    condition     = aws_rds_cluster.this.serverlessv2_scaling_configuration[0].min_capacity == 0.5
    error_message = "Serverless v2 min_capacity must come from the caller."
  }

  assert {
    condition     = aws_rds_cluster.this.serverlessv2_scaling_configuration[0].max_capacity == 16
    error_message = "Serverless v2 max_capacity must come from the caller."
  }
}

run "omits_serverless_scaling_for_other_modes" {
  command = plan

  variables {
    engine_mode = "serverless"
  }

  assert {
    condition     = length(aws_rds_cluster.this.serverlessv2_scaling_configuration) == 0
    error_message = "Serverless v2 scaling must not be set when engine_mode is not provisioned."
  }
}
