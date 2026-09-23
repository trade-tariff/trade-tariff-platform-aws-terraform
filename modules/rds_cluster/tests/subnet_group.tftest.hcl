mock_provider "aws" {}
mock_provider "random" {}

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

run "creates_a_subnet_group_by_default" {
  command = plan

  assert {
    condition     = length(aws_db_subnet_group.rds_private_subnet) == 1
    error_message = "A subnet group must be created by default."
  }

  assert {
    condition     = aws_db_subnet_group.rds_private_subnet[0].name == "tariff-cluster-sg"
    error_message = "The subnet group must be named <cluster_name>-sg."
  }

  assert {
    condition     = aws_rds_cluster.this.db_subnet_group_name == "tariff-cluster-sg"
    error_message = "The cluster must use the subnet group that the module creates."
  }

  assert {
    condition     = aws_rds_cluster_instance.this[0].db_subnet_group_name == "tariff-cluster-sg"
    error_message = "The instances must use the subnet group that the module creates."
  }
}

run "uses_an_existing_subnet_group_when_asked" {
  command = plan

  variables {
    create_subnet_group  = false
    db_subnet_group_name = "existing-subnet-group"
  }

  assert {
    condition     = length(aws_db_subnet_group.rds_private_subnet) == 0
    error_message = "No subnet group must be created when create_subnet_group is false."
  }

  assert {
    condition     = aws_rds_cluster.this.db_subnet_group_name == "existing-subnet-group"
    error_message = "The cluster must use the subnet group name that the caller gives."
  }

  assert {
    condition     = aws_rds_cluster_instance.this[0].db_subnet_group_name == "existing-subnet-group"
    error_message = "The instances must use the subnet group name that the caller gives."
  }
}
