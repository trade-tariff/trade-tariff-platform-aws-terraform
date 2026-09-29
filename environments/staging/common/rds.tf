locals {
  # Common parameters for ALL databases (both RDS and Aurora).
  common_parameters = [
    {
      name         = "log_connections"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_disconnections"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_replication_commands"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "log_error_verbosity"
      value        = "VERBOSE"
      apply_method = "immediate"
    },
    {
      name         = "log_line_prefix"
      value        = "%m:%r:%u@%d:[%p]:%l:%e:%s:%v:%x:%c:%q%a:"
      apply_method = "immediate"
    },
    {
      name         = "log_statement"
      value        = "ddl"
      apply_method = "immediate"
    },
    {
      name         = "log_min_duration_statement"
      value        = "5000"
      apply_method = "immediate"
    },
    {
      name         = "ssl_min_protocol_version"
      value        = "TLSv1.3"
      apply_method = "immediate"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pgaudit,pg_stat_statements"
      apply_method = "pending-reboot"
    },
    {
      name         = "pgaudit.log"
      value        = "WRITE,DDL,ROLE"
      apply_method = "immediate"
    },
    {
      name         = "pgaudit.log_catalog"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "pgaudit.log_parameter"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "pgaudit.role"
      value        = "rds_pgaudit"
      apply_method = "immediate"
    }
  ]

  aurora_connection_parameters = [
    # NOTE: Detect dead clients while a query is executing instead of waiting for the
    # statement to finish. Value is milliseconds.
    {
      name         = "client_connection_check_interval"
      value        = "30000" # 30 seconds (default is 0/off)
      apply_method = "pending-reboot"
    },
    # NOTE: Fail sessions that sit idle inside a transaction for more than 10 minutes
    # so they do not hold locks or prevent cleanup indefinitely. Not strictly an aurora-only setting
    {
      name         = "idle_in_transaction_session_timeout"
      value        = "600000"
      apply_method = "immediate"
    }
  ]

  # NOTE: Some parameter VALUES are only valid on certain engine majors, so the PG18
  # parameter groups cannot reuse common_parameters verbatim while PG17 is still live.
  # log_connections was a boolean up to PG17; in PG18 it became a list of connection
  # aspects, and "all" is the equivalent of the old positive boolean.
  pg18_parameter_overrides = {
    log_connections = "all"
  }

  pg18_common_parameters = [
    for parameter in local.common_parameters : merge(parameter, {
      value = lookup(local.pg18_parameter_overrides, parameter.name, parameter.value)
    })
  ]
}

module "postgres_developer_hub" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "PostgresDeveloperHub"
  engine_version = "18.3"

  multi_az = false

  instance_type      = "db.t3.micro"
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage  = 10
  security_group_ids = [module.alb-security-group.be_to_rds_security_group_id]

  secret_kms_key_arn = aws_kms_key.secretsmanager_kms_key.arn

  depends_on = [
    module.alb-security-group
  ]

  tags = {
    Name       = "DeveloperHubPostgres${title(var.environment)}"
    "RDS_Type" = "Instance"
  }
}

# Aurora cluster
module "postgres_aurora" {
  source = "../../../modules/rds_cluster"

  cluster_name      = "postgres-aurora-${var.environment}"
  engine_version    = "17.7"
  engine_mode       = "provisioned"
  cluster_instances = 2
  apply_immediately = true

  instance_class = "db.serverless"
  database_name  = "TradeTariffPostgres${title(var.environment)}"
  username       = "tariff"

  min_capacity = 0.5
  max_capacity = 10

  security_group_ids = [module.alb-security-group.be_to_rds_security_group_id]
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_pg_17.name

  cloudwatch_log_exports = ["postgresql"]

  tags = {
    "RDS_Type" = "Aurora"
  }
}

module "rw_aurora_connection_string" {
  source          = "../../../modules/secret/"
  name            = "aurora-postgres-rw-connection-string"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.postgres_aurora.rw_connection_string
}

module "ro_aurora_connection_string" {
  source          = "../../../modules/secret/"
  name            = "aurora-postgres-ro-connection-string"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.postgres_aurora.ro_connection_string
}

module "postgres_admin_aurora" {
  source = "../../../modules/rds_cluster"

  cluster_name      = "admin-aurora-${var.environment}"
  engine_version    = "17.7"
  engine_mode       = "provisioned"
  cluster_instances = 1
  apply_immediately = true

  instance_class = "db.serverless"
  database_name  = "PostgresAdmin"
  username       = "tariff"

  encryption_at_rest = true

  cloudwatch_log_exports = ["postgresql"]

  min_capacity = 0.5
  max_capacity = 2

  security_group_ids = [module.alb-security-group.be_to_rds_security_group_id]
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.admin_aurora_pg_17.name

  tags = {
    "RDS_Type" = "Aurora"
  }
}

module "admin_connection_string" {
  source          = "../../../modules/secret/"
  name            = "admin-connection-string"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.postgres_admin_aurora.rw_connection_string
}

//////////////////////////////////////////////////////////////////////////
# Aurora cluster Parameter Groups
//////////////////////////////////////////////////////////////////////////

# TODO Channge the name to be more generic after upgrade to Aurora Postgres 18.
resource "aws_rds_cluster_parameter_group" "aurora_pg_17" {
  name        = "postgres-aurora-staging-cpg-20260313202704249200000001"
  family      = "aurora-postgresql17"
  description = "Managed PostgreSQL cluster parameter group for postgres-aurora-staging."

  # Common parameters
  dynamic "parameter" {
    for_each = concat(local.common_parameters, local.aurora_connection_parameters)
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "RDS_Type" = "Aurora"
  }
}

# TODO Channge the name to be more generic after upgrade to Aurora Postgres 18.
resource "aws_rds_cluster_parameter_group" "admin_aurora_pg_17" {
  name        = "admin-aurora-staging-cpg-20260316134422903000000002"
  family      = "aurora-postgresql17"
  description = "Managed PostgreSQL cluster parameter group for admin-aurora-staging."

  # Common parameters
  dynamic "parameter" {
    for_each = local.common_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "RDS_Type" = "Aurora"
  }
}

//////////////////////////////////////////////////////////////////////////
# Aurora PostgreSQL 18 cluster parameter groups
#
# Created ahead of the Blue/Green major version upgrade: the Create Blue/Green
# Deployment dialog requires the target-family group to already exist, and an
# aurora-postgresql18 group cannot be attached to a cluster still running 17.
# The clusters are re-pointed at these groups in the follow-up cutover PR.
//////////////////////////////////////////////////////////////////////////

resource "aws_rds_cluster_parameter_group" "aurora_pg_18" {
  name        = "postgres-aurora-${var.environment}-cpg-18"
  family      = "aurora-postgresql18"
  description = "Managed PostgreSQL cluster parameter group for postgres-aurora-${var.environment}."

  # Common parameters
  dynamic "parameter" {
    for_each = concat(local.pg18_common_parameters, local.aurora_connection_parameters)
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "RDS_Type" = "Aurora"
  }
}

resource "aws_rds_cluster_parameter_group" "admin_aurora_pg_18" {
  name        = "admin-aurora-${var.environment}-cpg-18"
  family      = "aurora-postgresql18"
  description = "Managed PostgreSQL cluster parameter group for admin-aurora-${var.environment}."

  # Common parameters
  dynamic "parameter" {
    for_each = local.pg18_common_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "RDS_Type" = "Aurora"
  }
}
