locals {
  newrelic_endpoint = var.newrelic_datacenter == "US" ? "https://aws-api.newrelic.com/cloudwatch-metrics/v1" : "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose-to-nr-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  role = aws_iam_role.firehose_role.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${var.firehose_backups_bucket}",
            "arn:aws:s3:::${var.firehose_backups_bucket}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "logs:PutLogEvents"
          ]
          Resource = ["*"]
        },
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ],
          Resource = ["*"]
        }

      ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "nr_stream" {
  name        = "cloudwatch-to-newrelic-${var.environment}"
  destination = "http_endpoint"

  http_endpoint_configuration {
    url                = local.newrelic_endpoint
    name               = "NewRelic"
    access_key         = var.newrelic_license_key
    buffering_interval = 60
    buffering_size     = 1
    retry_duration     = 60
    role_arn           = aws_iam_role.firehose_role.arn
    s3_backup_mode     = "FailedDataOnly"

    s3_configuration {
      bucket_arn         = var.firehose_backups_bucket
      role_arn           = aws_iam_role.firehose_role.arn
      buffering_interval = 400
      buffering_size     = 10
      compression_format = "GZIP"
    }

    request_configuration {
      content_encoding = "GZIP"
    }
  }
}
