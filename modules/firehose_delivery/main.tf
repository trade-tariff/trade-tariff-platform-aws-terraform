locals {
  newrelic_endpoint = var.newrelic_datacenter == "US" ? "https://aws-api.newrelic.com/cloudwatch-metrics/v1" : "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1"
}

resource "aws_iam_role" "firehose_role" {
  name = "newrelic-firehose-role-${var.environment}"
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
            var.firehose_backups_bucket,
            "${var.firehose_backups_bucket}/*"
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
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ],
          Resource = "*"
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
    buffering_interval = 60 # seconds
    buffering_size     = 1  # MB
    retry_duration     = 60 # seconds
    role_arn           = aws_iam_role.firehose_role.arn
    s3_backup_mode     = "FailedDataOnly"

    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = var.firehose_backups_bucket
      buffering_interval = 400
      buffering_size     = 10
      compression_format = "GZIP"

      cloudwatch_logging_options {
        enabled        = true
        log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
      }
    }

    request_configuration {
      content_encoding = "GZIP"
    }

    cloudwatch_logging_options {
      enabled        = true
      log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
    }
  }
}

resource "aws_cloudwatch_log_group" "firehose_log_group" {
  name              = "/aws/kinesisfirehose/cloudwatch-to-newrelic"
  retention_in_days = 7
}
