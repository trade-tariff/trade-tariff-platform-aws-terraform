mock_provider "aws" {
  # The endpoints are unknown at plan. Fixed values let the runs check
  # how the module builds the connection strings.
  override_resource {
    target          = aws_rds_cluster.this
    override_during = plan
    values = {
      endpoint        = "tariff-cluster.cluster-abc123.eu-west-2.rds.amazonaws.com"
      reader_endpoint = "tariff-cluster.cluster-ro-abc123.eu-west-2.rds.amazonaws.com"
    }
  }
}

mock_provider "random" {
  override_resource {
    target          = random_password.master_password
    override_during = plan
    values = {
      result = "test-password_16"
    }
  }
}

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

run "uses_the_generated_password" {
  command = plan

  assert {
    condition     = nonsensitive(aws_rds_cluster.this.master_password) == "test-password_16"
    error_message = "The cluster master password must be the generated random password."
  }
}

run "builds_the_read_write_connection_string" {
  command = plan

  assert {
    condition     = nonsensitive(output.rw_connection_string) == format("postgres://%s:%s@%s/%s", "tariff_admin", "test-password_16", "tariff-cluster.cluster-abc123.eu-west-2.rds.amazonaws.com", "tariff")
    error_message = "rw_connection_string must be postgres://<user>:<password>@<writer endpoint>/<database>."
  }
}

run "builds_the_read_only_connection_string" {
  command = plan

  assert {
    condition     = nonsensitive(output.ro_connection_string) == format("postgres://%s:%s@%s/%s", "tariff_admin", "test-password_16", "tariff-cluster.cluster-ro-abc123.eu-west-2.rds.amazonaws.com", "tariff")
    error_message = "ro_connection_string must be postgres://<user>:<password>@<reader endpoint>/<database>."
  }
}
