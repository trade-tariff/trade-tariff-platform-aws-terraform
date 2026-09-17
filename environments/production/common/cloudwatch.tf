module "cloudwatch-ecs-logs" {
  source            = "../../../modules/cloudwatch/"
  name              = "platform-logs-${var.environment}"
  retention_in_days = 1096
}

module "cloudwatch-rds-logs" {
  source            = "../../../modules/cloudwatch/"
  name              = "/aws/rds/cluster/postgres-aurora-${var.environment}/postgresql"
  retention_in_days = 30

}

data "aws_iam_policy_document" "logs_bucket_policy" {
  statement {
    sid    = "AllowLogsExportGetBucketAcl"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.eu-west-2.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::trade-tariff-logs-${local.account_id}"]
  }

  statement {
    sid    = "AllowLogsExportPutObject"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.eu-west-2.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::trade-tariff-logs-${local.account_id}",
      "arn:aws:s3:::trade-tariff-logs-${local.account_id}/*"
    ]
  }
}

resource "aws_kms_key" "logs_bucket_kms_key" {
  description             = "KMS key for encrypting log buckets."
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "logs_bucket_kms_alias" {
  name          = "alias/log-buckets-key"
  target_key_id = aws_kms_key.logs_bucket_kms_key.key_id
}

resource "aws_kms_key_policy" "logs_bucket_kms_key_policy" {
  key_id = aws_kms_key.logs_bucket_kms_key.id
  policy = jsonencode({
    Id = "key-default-1"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Principal = {
          Service = "logs.eu-west-2.amazonaws.com"
        }
        Resource = "*"
        Sid      = "Allow CWL Service Principal usage"
      },
      {
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:role/log-exporter-${var.environment}"
        }
        Resource = "arn:aws:kms:eu-west-2:${local.account_id}:key/${aws_kms_key.logs_bucket_kms_key.id}"
        Sid      = "Enable log exporter IAM Role Permissions"
      }
    ]
    Version = "2012-10-17"
  })
}

module "logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.1"

  bucket = "trade-tariff-logs-${local.account_id}"
  acl    = "log-delivery-write"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.logs_bucket_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # Bucket policies
  attach_policy = true
  policy        = data.aws_iam_policy_document.logs_bucket_policy.json

  lifecycle_rule = [{
    id      = "log"
    enabled = true

    transition = [{
      days          = 90
      storage_class = "DEEP_ARCHIVE"
    }]

    expiration = {
      days = 1096
    }
  }]
}

module "cloudwatch-logs-exporter" {
  source                        = "../../../modules/cloudwatch_log_exporter"
  cloudwatch_logs_export_bucket = "trade-tariff-logs-${local.account_id}"
  environment                   = var.environment
  log_retention_days            = 30
}

resource "aws_cloudwatch_dashboard" "e2e_metrics" {
  dashboard_name = "trade-tariff-e2e-production"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "Run outcome"
          region = "eu-west-2"
          metrics = [
            ["TradeTariff/E2E", "TestsPassed", "Environment", "production"],
            [".", "TestsFailed", ".", "."],
            [".", "TestsSkipped", ".", "."],
          ]
          # 600s matches the scheduler's ten minute cadence. A shorter period
          # would read as missing data for most of every interval.
          period = 600
          stat   = "Maximum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title   = "Run duration (ms)"
          region  = "eu-west-2"
          metrics = [["TradeTariff/E2E", "RunDuration", "Environment", "production"]]
          period  = 600
          stat    = "Average"
          view    = "timeSeries"
          yAxis   = { left = { min = 0 } }
        }
      },
      {
        type   = "metric"
        width  = 24
        height = 8
        properties = {
          title  = "Slowest journeys (ms)"
          region = "eu-west-2"
          metrics = [
            [{ expression = "SORT(SEARCH('{TradeTariff/E2E,Environment,Spec,Test} MetricName=\"TestDuration\" Environment=\"production\"', 'Average', 600), AVG, DESC, 15)" }]
          ]
          period = 600
          view   = "timeSeries"
          yAxis  = { left = { min = 0 } }
        }
      },
    ]
  })
}
