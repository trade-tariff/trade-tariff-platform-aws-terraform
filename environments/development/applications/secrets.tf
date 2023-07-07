resource "aws_secretsmanager_secret" "frontend_secret_key_base" {
  name       = "frontend-secret-key-base"
  kms_key_id = data.terraform_remote_state.base.outputs.secretsmanager_kms_key_arn
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
