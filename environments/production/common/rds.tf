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
      apply_method = "pending-reboot"
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
}

module "postgres_commodi_tea" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "PostgresCommodiTea"
  engine         = "postgres"
  engine_version = "18.3"

  deletion_protection = false
  multi_az            = false

  instance_type           = "db.t3.micro"
  backup_window           = "22:00-23:00"
  maintenance_window      = "Fri:23:00-Sat:01:00"
  backup_retention_period = 7
  private_subnet_ids      = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage  = 10
  security_group_ids = [module.alb-security-group.be_to_rds_security_group_id]

  secret_kms_key_arn = aws_kms_key.secretsmanager_kms_key.arn

  depends_on = [
    module.alb-security-group
  ]

  tags = {
    Name       = "PostgresCommodiTea"
    customer   = "fpo"
    "RDS_Type" = "Instance"
  }
}

# Aurora cluster
module "postgres_aurora_16_8" {
  source = "../../../modules/rds_cluster"

  cluster_name      = "postgres-aurora-${var.environment}-16-8"
  engine            = "aurora-postgresql"
  engine_version    = "17.7"
  engine_mode       = "provisioned"
  cluster_instances = 2
  apply_immediately = true

  instance_class = "db.serverless"
  database_name  = "TradeTariffPostgres${title(var.environment)}"
  username       = "tariff"

  encryption_at_rest = true

  performance_insights_enabled = true

  min_capacity = 2
  max_capacity = 64

  security_group_ids = [module.alb-security-group.be_to_rds_security_group_id]
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_pg_17.name

  cloudwatch_log_exports = ["postgresql"]

  tags = {
    "RDS_Type" = "Aurora"
  }
}

module "postgres_database_url" {
  source          = "../../../modules/secret/"
  name            = "${var.environment}-postgres-database-url"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.postgres_aurora_16_8.rw_connection_string
}

module "postgres_admin_aurora" {
  source = "../../../modules/rds_cluster"

  cluster_name      = "admin-aurora-${var.environment}"
  engine            = "aurora-postgresql"
  engine_version    = "17.7"
  engine_mode       = "provisioned"
  cluster_instances = 1
  apply_immediately = true

  instance_class = "db.serverless"
  database_name  = "PostgresAdmin"
  username       = "tariff"

  encryption_at_rest = true

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

module "postgres_developer_hub" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "PostgresDeveloperHub"
  engine         = "postgres"
  engine_version = "18.3"

  deletion_protection = false
  multi_az            = false

  instance_type           = "db.t3.micro"
  backup_window           = "22:00-23:00"
  maintenance_window      = "Fri:23:00-Sat:01:00"
  backup_retention_period = 7
  private_subnet_ids      = data.terraform_remote_state.base.outputs.private_subnet_ids

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

//////////////////////////////////////////////////////////////////////////
# Aurora cluster Parameter Groups
//////////////////////////////////////////////////////////////////////////
resource "aws_rds_cluster_parameter_group" "aurora_pg_17" {
  name        = "postgres-aurora-17-cpg-${var.environment}"
  family      = "aurora-postgresql17"
  description = "Managed PostgreSQL cluster parameter group for Aurora Postgres 17 ${var.environment}."

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

# TODO Channge the name to be more generic after upgrade to Aurora Postgres 18.
resource "aws_rds_cluster_parameter_group" "admin_aurora_pg_17" {
  name        = "admin-aurora-production-cpg-20260310174358017900000001"
  family      = "aurora-postgresql17"
  description = "Managed PostgreSQL cluster parameter group for admin-aurora-production."

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
