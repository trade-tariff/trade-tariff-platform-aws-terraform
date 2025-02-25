# Backend Postgres
module "postgres" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "TradeTariffPostgres${title(var.environment)}"
  engine         = "postgres"
  engine_version = "13.15"

  deletion_protection = true

  instance_type = "db.m5.4xlarge"
  multi_az      = true

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
    Name       = "TradeTariffPostgres${title(var.environment)}"
    "RDS_Type" = "Instance"
  }
}


module "read_only_postgres_connection_string" {
  source          = "../../../modules/secret/"
  name            = "postgres-read-only"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = "postgres://tariff_read:tariff@${module.postgres.userless_connection_string}"
}

# Admin Postgres
module "postgres_admin" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "PostgresAdmin"
  engine         = "postgres"
  engine_version = "13.15"

  deletion_protection = true

  instance_type      = "db.t3.micro"
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
    Name       = "PostgresAdmin"
    "RDS_Type" = "Instance"
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
    Name       = "PostgresCommodiTea"
    customer   = "fpo"
    "RDS_Type" = "Instance"
  }
}

# Aurora cluster
module "postgres_aurora" {
  source = "../../../modules/rds_cluster"

  cluster_name      = "postgres-aurora-${var.environment}"
  engine            = "aurora-postgresql"
  engine_version    = "13.15"
  engine_mode       = "provisioned"
  cluster_instances = 2
  apply_immediately = true

  instance_class = "db.serverless"
  database_name  = "TradeTariffPostgres${title(var.environment)}"
  username       = "tariff"

  encryption_at_rest = true

  # TODO: monitor capacity in production
  min_capacity = 16
  max_capacity = 64

  security_group_ids = [module.alb-security-group.be_to_rds_security_group_id]
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

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
