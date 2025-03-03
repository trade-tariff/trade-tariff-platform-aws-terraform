# Backend Postgres
module "postgres" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "TradeTariffPostgres${title(var.environment)}"
  engine         = "postgres"
  engine_version = "13.15"

  deletion_protection = false # while configuring

  instance_type      = "db.t3.medium"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage     = 20
  max_allocated_storage = 40
  security_group_ids    = [module.alb-security-group.be_to_rds_security_group_id]

  secret_kms_key_arn = aws_kms_key.secretsmanager_kms_key.arn

  depends_on = [
    module.alb-security-group
  ]

  tags = {
    Name = "TradeTariffPostgres${title(var.environment)}"
  }
}

module "read_only_postgres_connection_string" {
  source          = "../../../modules/secret/"
  name            = "postgres-read-only"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = "postgres://tariff_read:tariff@${module.postgres.userless_connection_string}"
}

# Signon MySQL
module "mysql" {
  source = "../../../modules/rds"

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

  tags = {
    Name = "TradeTariffMySQL${title(var.environment)}"
  }
}

module "postgres_commodi_tea" {
  source = "../../../modules/rds"

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

  depends_on = [
    module.alb-security-group
  ]

  tags = {
    Name     = "PostgresCommodiTea"
    customer = "fpo"
  }
}

module "postgres_admin_aurora" {
  source = "../../../modules/rds_cluster"

  cluster_name      = "admin-aurora-${var.environment}"
  engine            = "aurora-postgresql"
  engine_version    = "13.15"
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
