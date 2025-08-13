resource "aws_cloudwatch_metric_stream" "nr_metric_stream" {
  name          = "cw-metric-stream-nr-${var.environment}"
  role_arn      = aws_iam_role.metric_stream_role.arn
  firehose_arn  = var.firehose_arn
  output_format = "opentelemetry0.7"

  dynamic "include_filter" {
    for_each = var.namespaces
    content {
      namespace = include_filter.value
    }
  }
}

resource "aws_iam_role" "metric_stream_role" {
  name = "metric-stream-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "streams.metrics.cloudwatch.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "metric_stream_policy" {
  role = aws_iam_role.metric_stream_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["firehose:PutRecord", "firehose:PutRecordBatch"]
        Resource = var.firehose_arn
      }
    ]
  })
}
