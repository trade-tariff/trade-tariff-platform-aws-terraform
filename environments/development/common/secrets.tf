resource "aws_secretsmanager_secret" "frontend_secret_key_base" {
  name       = "frontend-secret-key-base"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "frontend_secret_key_base_value" {
  secret_id     = aws_secretsmanager_secret.frontend_secret_key_base.id
  secret_string = var.frontend_secret_key_base
}

variable "frontend_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the frontend."
  type        = string
  sensitive   = true
}

resource "aws_secretsmanager_secret" "newrelic_license_key" {
  name       = "newrelic-license-key"
  kms_key_id = aws_kms_key.secretsmanager_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "newrelic_license_key_value" {
  secret_id     = aws_secretsmanager_secret.newrelic_license_key.id
  secret_string = var.newrelic_license_key
}

variable "newrelic_license_key" {
  description = "License key for NewRelic."
  type        = string
  sensitive   = true
}
