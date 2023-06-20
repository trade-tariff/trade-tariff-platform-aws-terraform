module "postgres" {
  source = "../../common/rds"

  name           = "trade-tariff-postgres-${var.environment}"
  engine         = "postgres"
  engine_version = "13.11"

  instance_type      = "db.t2.micro"         # for now, the smallest one we can use.
  backup_window      = "18:00-19:00"         # check with wider team
  maintenance_window = "Fri:23:00-Sat:01:00" # check with wider team

  region = var.region
}
