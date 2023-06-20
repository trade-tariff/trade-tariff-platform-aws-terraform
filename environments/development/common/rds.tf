module "postgres" {
  source = "../../common/rds"

  name           = "trade-tariff-postgres-${var.environment}"
  engine         = "postgres"
  engine_version = "13.11"

  instance_type      = "db.t2.micro" # for now, the smallest one we can use.
  backup_window      = "22:00-23:00"
  maintenance_window = "Fri:23:00-Sat:01:00"

  region = var.region
}
