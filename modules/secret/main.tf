resource "aws_secretsmanager_secret" "this" {
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window
  name                    = var.name
}

moved {
  from = aws_secretsmanager_secret_version.this
  to   = aws_secretsmanager_secret_version.managed
}

resource "aws_secretsmanager_secret_version" "managed" {
  count         = var.secret_string != "" && !var.ignore_secret_string_changes ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string
}

resource "aws_secretsmanager_secret_version" "bootstrap" {
  count         = var.secret_string != "" && var.ignore_secret_string_changes ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string

  lifecycle {
    ignore_changes = [secret_string]
  }
}
