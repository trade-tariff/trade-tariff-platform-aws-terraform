mock_provider "aws" {
  # The group name comes from name_prefix and is unknown at plan.
  override_resource {
    target          = aws_db_parameter_group.postgres
    override_during = plan
    values = {
      name = "tariff-pg-20260101000000000000000001"
    }
  }
}

mock_provider "random" {}

variables {
  environment        = "staging"
  name               = "Tariff"
  engine_version     = "16.4"
  instance_type      = "db.t4g.micro"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111"]
  secret_kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
}

run "creates_a_parameter_group_for_the_postgres_major_version" {
  command = plan

  assert {
    condition     = aws_db_parameter_group.postgres.family == "postgres16"
    error_message = "The parameter group family must be postgres<major version>."
  }

  assert {
    condition     = aws_db_parameter_group.postgres.name_prefix == "tariff-pg-"
    error_message = "The parameter group name prefix must be the lower case database name."
  }
}

run "instance_uses_the_module_parameter_group" {
  command = plan

  assert {
    condition     = aws_db_instance.this.parameter_group_name == "tariff-pg-20260101000000000000000001"
    error_message = "The instance must use the parameter group that the module creates."
  }
}

run "requires_tls_1_3" {
  command = plan

  assert {
    condition = anytrue([
      for parameter in aws_db_parameter_group.postgres.parameter :
      parameter.name == "ssl_min_protocol_version" && parameter.value == "TLSv1.3"
    ])
    error_message = "The parameter group must require TLS 1.3 or later."
  }
}

run "turns_on_pgaudit" {
  command = plan

  assert {
    condition = anytrue([
      for parameter in aws_db_parameter_group.postgres.parameter :
      parameter.name == "shared_preload_libraries" && parameter.value == "pgaudit,pg_stat_statements" && parameter.apply_method == "pending-reboot"
    ])
    error_message = "pgaudit and pg_stat_statements must be preloaded (this needs a reboot to apply)."
  }

  assert {
    condition = anytrue([
      for parameter in aws_db_parameter_group.postgres.parameter :
      parameter.name == "pgaudit.role" && parameter.value == "rds_pgaudit"
    ])
    error_message = "pgaudit.role must be rds_pgaudit, the role name that RDS needs for object auditing."
  }
}

run "exports_postgres_logs_to_cloudwatch" {
  command = plan

  assert {
    condition     = aws_db_instance.this.enabled_cloudwatch_logs_exports == toset(["postgresql", "upgrade"])
    error_message = "Postgres and upgrade logs must be exported to CloudWatch."
  }
}
