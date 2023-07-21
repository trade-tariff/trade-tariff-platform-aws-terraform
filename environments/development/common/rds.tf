module "postgres" {
  source = "../../../modules/rds"

  name           = local.database_name
  engine         = "postgres"
  engine_version = "13.11"

  deletion_protection = false # while configuring

  # smallest that supports encryption at rest and postgres 13.11
  instance_type      = "db.t3.micro"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"

  allocated_storage     = 10
  max_allocated_storage = 20

  region      = var.region
  environment = var.environment
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
  source          = "../../../modules/secret/"
  name            = "backend-database-connection-string"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = "postgres://${local.postgres_username}:${local.postgres_password}@${module.postgres.db_endpoint}/${local.database_name}"
}
