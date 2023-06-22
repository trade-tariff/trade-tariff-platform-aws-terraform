module "postgres" {
  source = "../../common/rds"

  name           = "TradeTariffPostgres${title(var.environment)}"
  engine         = "postgres"
  engine_version = "13.11"

  # smallest that supports encryption at rest and postgres 13.11
  instance_type      = "db.t3.micro"
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"

  region      = var.region
  environment = var.environment
}
