resource "random_string" "master_username" {
  length  = 7
  special = false
}

resource "random_string" "prefix" {
  length  = 1
  special = false
  numeric = false
}

resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "_-"
}

resource "random_string" "private_subnet_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "${lower(var.name)}-connection-string"
  kms_key_id              = var.secret_kms_key_arn
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = "${var.engine}://${local.master_username}:${local.master_password}@${aws_db_instance.this.endpoint}/${var.name}"
}
