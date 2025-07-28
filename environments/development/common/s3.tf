locals {
  buckets = {
    tech-docs         = "trade-tariff-tech-docs-${local.account_id}"
    api-docs          = "trade-tariff-api-docs-${local.account_id}"
    database-backups  = "trade-tariff-database-backups-${local.account_id}"
    lambda-deployment = "trade-tariff-lambda-deployment-${local.account_id}"
    persistence       = "trade-tariff-persistence-${local.account_id}"
    reporting         = "trade-tariff-reporting-${local.account_id}"
    ses-inbound       = "trade-tariff-ses-inbound-${local.account_id}"
    preevy-profile    = "preevy-profile-store"
  }
  buckets_with_versioning = {
    persistence = local.buckets.persistence
  }
  buckets_to_rotate = {
    database-backups = {
      bucket = local.buckets.database-backups
      days   = 60
      prefix = ""
    }
    ses-inbound = {
      bucket = local.buckets.ses-inbound
      days   = 1
      prefix = "inbound/"
    }
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

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.buckets_with_versioning
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

resource "aws_s3_bucket_policy" "ses_policy" {
  bucket = aws_s3_bucket.this["ses-inbound"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.this["ses-inbound"].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = local.account_id
            "AWS:SourceArn"     = "arn:aws:ses:${var.region}:${local.account_id}:identity/${var.domain_name}"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket.this]
}

resource "aws_iam_role" "ses_s3" {
  name = "ses-s3-write-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ses.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ses_s3_policy" {
  role = aws_iam_role.ses_s3.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.this["ses-inbound"].arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ],
        Resource = aws_kms_key.s3.arn
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = local.buckets_to_rotate
  bucket   = each.value.bucket

  rule {
    id     = "Rotate ${each.key} bucket"
    status = "Enabled"

    expiration {
      days = each.value.days
    }

    filter {
      prefix = each.value.prefix
    }
  }
}
