locals {
  buckets = {
    persistence          = "${var.project}-persistence-${var.environment}-${var.aws_account_id}"
    tariff-pdf           = "${var.project}-tariff-pdf-${var.environment}-${var.aws_account_id}"
    search-configuration = "${var.project}-trade-tariff-search-configuration-${var.environment}-${var.aws_account_id}"
  }
}

resource "aws_kms_key" "this" {
  description         = "This key is used to encrypt bucket objects"
  enable_key_rotation = true
}

# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  tags     = var.s3_tags
  bucket   = each.value

  force_destroy = false
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
