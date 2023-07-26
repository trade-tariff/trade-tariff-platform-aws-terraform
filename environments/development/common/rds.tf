module "postgres" {
  source = "../../common/rds"

  environment    = var.environment
  name           = local.database_name
  engine         = "postgres"
  engine_version = "13.11"

  deletion_protection = false # while configuring

  # smallest that supports encryption at rest and postgres 13.11
  instance_type      = "db.t3.micro"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids

  allocated_storage     = 20
  max_allocated_storage = 40
  security_group_ids    = [module.alb-security-group.be_to_rds_security_group_id]

  depends_on = [
    module.alb-security-group
  ]
}

data "aws_secretsmanager_secret_version" "postgres_master_user_details" {
  secret_id = module.postgres.master_user_secret
}

locals {
  postgres_username = urlencode(jsondecode(data.aws_secretsmanager_secret_version.postgres_master_user_details.secret_string)["username"])
  postgres_password = urlencode(jsondecode(data.aws_secretsmanager_secret_version.postgres_master_user_details.secret_string)["password"])
  database_name     = "TradeTariffPostgres${title(var.environment)}"
}

module "backend_database_connection_string" {
  source          = "../../common/secret/"
  name            = "backend-database-connection-string"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = "postgres://${local.postgres_username}:${local.postgres_password}@${module.postgres.db_endpoint}/${local.database_name}"
}
