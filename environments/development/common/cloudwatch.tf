resource "aws_cloudwatch_log_group" "this" {
  name              = "trade-tariff-logs-${var.environment}"
  retention_in_days = 7
  skip_destroy      = true
  kms_key_id        = aws_kms_key.this.arn
  depends_on        = [aws_kms_key.this]
}

resource "aws_kms_key" "this" {
  description             = "KMS key to encrypt CloudWatch logs."
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    Effect = "Allow",
    Principal = {
      Service = "logs.${var.region}.amazonaws.com"
    },
    Action = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ],
    Resource = aws_kms_key.this.arn
  })
}

resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/cloudwatch-${var.environment}"
  target_key_id = aws_kms_key.this.key_id
}
