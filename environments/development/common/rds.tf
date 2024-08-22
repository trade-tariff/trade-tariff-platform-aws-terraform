# Backend Postgres
module "postgres" {
  source = "../../../modules/common/rds"

  environment    = var.environment
  name           = "TradeTariffPostgres${title(var.environment)}"
  engine         = "postgres"
  engine_version = "13.13"

  deletion_protection = false # while configuring

  instance_type      = "db.t3.medium"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage     = 20
  max_allocated_storage = 40
  security_group_ids    = [module.alb-security-group.be_to_rds_security_group_id]

  secret_kms_key_arn = aws_kms_key.secretsmanager_kms_key.arn

  parameter_group_name = "default.postgres13"

  depends_on = [
    module.alb-security-group
  ]

  tags = {
    Name = "TradeTariffPostgres${title(var.environment)}"
  }
}

module "read_only_postgres_connection_string" {
  source          = "../../../modules/common/secret/"
  name            = "postgres-read-only"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = "postgres://tariff_read:tariff@${module.postgres.userless_connection_string}"
}

module "postgres_admin" {
  source = "../../../modules/common/rds"

  environment    = var.environment
  name           = "PostgresAdmin"
  engine         = "postgres"
  engine_version = "13.13"

  deletion_protection = false # while configuring

  # smallest that supports encryption at rest and postgres 13.13
  instance_type      = "db.t3.micro"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage     = 20
  max_allocated_storage = 40
  security_group_ids    = [module.alb-security-group.be_to_rds_security_group_id]

  secret_kms_key_arn = aws_kms_key.secretsmanager_kms_key.arn

  parameter_group_name = "default.postgres13"

  depends_on = [
    module.alb-security-group
  ]

  tags = {
    Name = "PostgresAdmin"
  }
}

# Signon MySQL
module "mysql" {
  source = "../../../modules/common/rds"

  environment    = var.environment
  name           = "TradeTariffMySQL${title(var.environment)}"
  engine         = "mysql"
  engine_version = "8.0"

  deletion_protection = false # in dev

  instance_type      = "db.t3.medium"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage     = 20
  max_allocated_storage = 40
  security_group_ids    = [module.alb-security-group.be_to_rds_security_group_id]

  secret_kms_key_arn = aws_kms_key.secretsmanager_kms_key.arn

  parameter_group_name = "default.mysql8.0"

  tags = {
    Name = "TradeTariffMySQL${title(var.environment)}"
  }
}

module "postgres_commodi_tea" {
  source = "../../../modules/common/rds"

  environment    = var.environment
  name           = "PostgresCommodiTea"
  engine         = "postgres"
  engine_version = "16.3"

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

  parameter_group_name = aws_db_parameter_group.tea.name

  depends_on = [
    module.alb-security-group
  ]

  tags = {
    Name     = "PostgresCommodiTea"
    customer = "fpo"
  }
}

resource "aws_db_parameter_group" "tea" {
  name        = "postgres16-with-md5-password-encryption"
  family      = "postgres16"
  description = "Managed by Terraform"

  parameter {
    name         = "password_encryption"
    value        = "md5"
    apply_method = "immediate"
  }

  tags = {
    Name     = "PostgresCommodiTea Parameter Group"
    customer = "fpo"
  }
}
