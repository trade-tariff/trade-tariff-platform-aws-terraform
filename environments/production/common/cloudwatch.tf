module "cloudwatch" {
  source            = "../../common/cloudwatch/"
  name              = "platform-logs-${var.environment}"
  retention_in_days = 30
}

module "logs" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.14.0"

  bucket = "trade-tariff-logs-${local.account_id}"
  acl    = "log-delivery-write"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.opensearch_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "log"
      enabled = true

      expiration = {
        days                         = 30
        expired_object_delete_marker = true
      }
    }
  ]
}
