locals {
  buckets = {
    api-docs = {
      name                        = "trade-tariff-api-docs-${local.account_id}"
      is_cdn_origin               = true
      cloudfront_distribution_arn = module.api_cdn.aws_cloudfront_distribution_arn
    }
    database-backups = {
      name                        = "trade-tariff-database-backups-${local.account_id}"
      is_cdn_origin               = true
      cloudfront_distribution_arn = module.backups_cdn.aws_cloudfront_distribution_arn
    }
    lambda-deployment = {
      name          = "trade-tariff-lambda-deployment-${local.account_id}"
      is_cdn_origin = false
    }
    persistence = {
      name          = "trade-tariff-persistence-${local.account_id}"
      is_cdn_origin = false
    }
    reporting = {
      name                        = "trade-tariff-reporting-${local.account_id}"
      is_cdn_origin               = true
      cloudfront_distribution_arn = module.reporting_cdn.aws_cloudfront_distribution_arn
    }
  }
}

resource "aws_kms_key" "s3" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = each.value.name
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
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = [for bucket in local.buckets : bucket if bucket.is_cdn_origin == true]

  bucket = aws_s3_bucket.this[each.key].id
  policy = data.aws_iam_policy_document.this[each.key].json

}

data "aws_iam_policy_document" "this" {
  for_each = [for bucket in local.buckets : bucket if bucket.is_cdn_origin == true]

  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.this[each.key].arn, "${aws_s3_bucket.this[each.key].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [each.value.cloudfront_distribution_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}
