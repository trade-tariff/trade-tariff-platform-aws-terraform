resource "aws_db_instance" "this" {
  db_name        = var.name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_type

  allocated_storage     = var.allocated_storage
  max_allocated_storage = local.max_allocated_storage
  storage_encrypted     = true
  db_subnet_group_name  = aws_db_subnet_group.rds_private_subnet.name
  multi_az              = var.multi_az

  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  skip_final_snapshot     = true

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  # apply db modifications during maintenance windows only
  # this prevents downtime as the server restarts
  apply_immediately = false

  username                            = local.master_username
  password                            = local.master_password
  iam_database_authentication_enabled = true

  performance_insights_enabled          = true
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = aws_kms_key.this.arn

  vpc_security_group_ids = var.security_group_ids

  parameter_group_name = var.parameter_group_name

  tags = local.tags
}

resource "aws_db_subnet_group" "rds_private_subnet" {
  name       = "subnet-group-${random_string.private_subnet_suffix.result}"
  subnet_ids = var.private_subnet_ids
  tags       = local.tags
}

resource "aws_kms_key" "this" {
  description         = "KMS key for the ${var.name} RDS instance on ${var.environment}."
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
  tags                = local.tags
}
