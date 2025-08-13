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
      Statement = [{
        Effect   = "Allow"
        Action   = ["logs:*", "s3:*", "kinesis:*"] # Restrict to specific resources and actions later
        Resource = "*"
      }]
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
      bucket_arn         = var.s3_backup_bucket
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
