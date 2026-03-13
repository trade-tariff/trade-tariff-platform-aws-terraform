resource "aws_db_instance" "this" {
  db_name        = var.name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_type

  allocated_storage     = var.allocated_storage
  max_allocated_storage = local.max_allocated_storage
  storage_encrypted     = true
  db_subnet_group_name  = aws_db_subnet_group.rds_private_subnet.name
  multi_az              = var.multi_az

  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  skip_final_snapshot     = true

  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  # apply db modifications during maintenance windows only
  # this prevents downtime as the server restarts
  apply_immediately = false

  username                            = local.master_username
  password                            = local.master_password
  iam_database_authentication_enabled = true

  performance_insights_enabled          = true
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = aws_kms_key.this.arn
  parameter_group_name                  = aws_db_parameter_group.postgres[0].name

  vpc_security_group_ids = var.security_group_ids

  tags = local.tags
}

resource "aws_db_parameter_group" "postgres" {
  count = local.postgres_parameter_group_family != null ? 1 : 0

  name_prefix = "${lower(var.name)}-pg-"
  family      = local.postgres_parameter_group_family
  description = "Managed Postgres parameter group for ${var.name}."

  parameter {
    name  = "log_connections"
    value = "all"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_replication_commands"
    value = "1"
  }

  parameter {
    name  = "ssl_min_protocol_version"
    value = "TLSv1.3"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pgaudit,pg_stat_statements"
    apply_method = "pending-reboot"
  }

  # TODO Starting point (tune later to control log volume)
  parameter {
    name         = "pgaudit.log"
    value        = "WRITE,DDL,ROLE"
    apply_method = "immediate"
  }

  parameter {
    name         = "pgaudit.log_catalog"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "pgaudit.log_parameter"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = "5000" # Log statements that run longer than 5 seconds
    apply_method = "immediate"
  }

  # RDS/Aurora require this special role name for object auditing
  parameter {
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
    apply_method = "immediate"
  }

  tags = local.tags
}

resource "aws_db_subnet_group" "rds_private_subnet" {
  name       = "subnet-group-${random_string.private_subnet_suffix.result}"
  subnet_ids = var.private_subnet_ids
  tags       = local.tags
}

resource "aws_kms_key" "this" {
  description         = "KMS key for the ${var.name} RDS instance on ${var.environment}."
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
  tags                = local.tags
}
