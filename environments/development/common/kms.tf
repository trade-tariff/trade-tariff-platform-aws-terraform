resource "aws_kms_key" "secretsmanager_kms_key" {
  description             = "KMS key for encrypting Secrets Manager secrets."
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "secretsmanager_kms_alias" {
  name          = "alias/secretsmanager-key"
  target_key_id = aws_kms_key.secretsmanager_kms_key.key_id
}
