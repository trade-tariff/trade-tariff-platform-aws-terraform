resource "aws_db_instance" "this" {
  db_name           = var.name
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_type
  allocated_storage = var.allocated_storage
  storage_encrypted = true

  deletion_protection     = true
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  # apply db modifications during maintenance windows only
  # this prevents downtime as the server restarts
  apply_immediately = false

  username                            = local.master_username
  manage_master_user_password         = true
  iam_database_authentication_enabled = true

  performance_insights_enabled          = true
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = aws_kms_key.this.arn

  vpc_security_group_ids = var.security_group_ids

  tags = local.tags
}

resource "aws_kms_key" "this" {
  description         = "KMS key for the ${var.name} RDS instance on ${var.environment}."
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
  tags                = local.tags
}

resource "random_string" "master_username" {
  length  = 7
  special = false
}

resource "random_string" "prefix" {
  length  = 1
  special = false
  numeric = false
}
