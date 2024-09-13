resource "aws_secretsmanager_secret" "this" {
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window
  name                    = var.name
}

resource "aws_secretsmanager_secret_version" "this" {
  count         = var.secret_string != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string
}
