# Backend Postgres
module "postgres" {
  source = "../../common/rds"

  environment    = var.environment
  name           = "TradeTariffPostgres${title(var.environment)}"
  engine         = "postgres"
  engine_version = "13.11"

  deletion_protection = true

  instance_type      = "db.t3.large"
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
}

# Admin Postgres
module "postgres_admin" {
  source = "../../common/rds"

  environment    = var.environment
  name           = "PostgresAdmin"
  engine         = "postgres"
  engine_version = "13.11"

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
}

# Signon MySQL
module "mysql" {
  source = "../../common/rds"

  environment    = var.environment
  name           = "TradeTariffMySQL${title(var.environment)}"
  engine         = "mysql"
  engine_version = "8.0"

  deletion_protection = true

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
}
