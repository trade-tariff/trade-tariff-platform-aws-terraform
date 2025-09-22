module "postgres_commodi_tea" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "PostgresCommodiTea"
  engine         = "postgres"
  engine_version = "16.8"

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
  engine_version    = "16.8"
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

module "postgres_developer_hub" {
  source = "../../../modules/rds"

  environment    = var.environment
  name           = "PostgresDeveloperHub"
  engine         = "postgres"
  engine_version = "17.4"

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
