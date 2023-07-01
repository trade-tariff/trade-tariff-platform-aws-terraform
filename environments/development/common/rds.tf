module "postgres" {
  source = "../../common/rds"

  name           = "TradeTariffPostgres${title(var.environment)}"
  engine         = "postgres"
  engine_version = "13.11"

  deletion_protection = false # while configuring

  # smallest that supports encryption at rest and postgres 13.11
  instance_type      = "db.t3.micro"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"

  region      = var.region
  environment = var.environment
}

resource "aws_secretsmanager_secret" "postgres_connection_string" {
  name       = "postgres-connection-string"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "postgres_connection_string_value" {
  secret_id     = aws_secretsmanager_secret.postgres_connection_string.id
  secret_string = module.postgres.db_endpoint
}
