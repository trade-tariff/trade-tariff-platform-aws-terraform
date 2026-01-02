locals {
  buckets = {
    tech-docs         = "trade-tariff-tech-docs-${local.account_id}"
    api-docs          = "trade-tariff-api-docs-${local.account_id}"
    database-backups  = "trade-tariff-database-backups-${local.account_id}"
    lambda-deployment = "trade-tariff-lambda-deployment-${local.account_id}"
    persistence       = "trade-tariff-persistence-${local.account_id}"
    reporting         = "trade-tariff-reporting-${local.account_id}"
    models            = "trade-tariff-models-${local.account_id}"
    firehose_backups  = "trade-tariff-firehose-backups-${local.account_id}"
  }
  buckets_with_versioning = {
    persistence = local.buckets.persistence
  }
}

resource "aws_kms_key" "s3" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
}

data "aws_iam_policy_document" "s3_kms_key_policy" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
      type        = "AWS"
    }
  }

  statement {
    sid    = "Enable Cross Account User Permissions"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = concat(
        [
          for account_id in values(var.account_ids) : "arn:aws:iam::${account_id}:role/backend-job-task-role"
        ],
        [
          for account_id in values(var.account_ids) : "arn:aws:iam::${account_id}:role/GithubActions-FPO-Models-Role"
        ],
        [
          for account_id in values(var.account_ids) : "arn:aws:iam::${account_id}:role/GithubActions-Serverless-Lambda-Role"
        ]
      )
    }
  }

  statement {
    sid       = "Allow use of the key for CloudFront OAC"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_kms_key_policy" "s3_kms_key_policy" {
  key_id = aws_kms_key.s3.key_id
  policy = data.aws_iam_policy_document.s3_kms_key_policy.json
}

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = each.value
}

# NOTE: Edge Lambda functions must be deployed from us-east-1
resource "aws_s3_bucket" "deployment-bucket-us-east-1" {
  bucket = "${local.buckets["lambda-deployment"]}-us-east-1"
  region = "us-east-1"
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.buckets_with_versioning

  bucket = aws_s3_bucket.this[each.key].id

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

resource "aws_s3_bucket_lifecycle_configuration" "database_backups_rotation" {
  bucket = aws_s3_bucket.this["database-backups"].id

  rule {
    id     = "rotate-database-backups"
    status = "Enabled"

    filter {}

    expiration {
      days = 60
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "firehose_backups_rotation" {
  bucket = aws_s3_bucket.this["firehose_backups"].id

  rule {
    id     = "rotate-firehose-backups"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

# NOTE: READONLY cross-account access for persistence bucket to allow backend jobs to replicate exchange rate data
data "aws_iam_policy_document" "persistence_cross_account_policy" {
  statement {
    sid    = "AllowCrossAccountReadAccess"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        for account_id in values(var.account_ids) : "arn:aws:iam::${account_id}:role/backend-job-task-role"
      ]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.this["persistence"].arn,
      "${aws_s3_bucket.this["persistence"].arn}/data/exchange_rates/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "persistence" {
  bucket = aws_s3_bucket.this["persistence"].id
  policy = data.aws_iam_policy_document.persistence_cross_account_policy.json
}
