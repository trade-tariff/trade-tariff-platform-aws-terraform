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
  min_capacity = 2
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
