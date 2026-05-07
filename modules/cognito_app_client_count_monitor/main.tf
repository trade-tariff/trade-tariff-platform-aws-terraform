data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/app_client_count.py"
  output_path = "${path.module}/lambda/tmp/app_client_count.zip"
}

resource "aws_iam_role" "this" {
  name = "trade-tariff-identity-app-client-count-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "lambda_execution" {
  statement {
    sid = "Logging"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${local.region}:${local.account_id}:*"]
  }

  statement {
    sid       = "ListUserPoolClients"
    actions   = ["cognito-idp:ListUserPoolClients"]
    resources = [var.user_pool_arn]
  }

  statement {
    sid    = "PutMetricData"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = [var.metric_namespace]
    }
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "trade-tariff-identity-app-client-count-${var.environment}"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.lambda_execution.json
}

resource "aws_lambda_function" "this" {
  function_name = "trade-tariff-identity-cognito-app-client-count-${var.environment}"
  role          = aws_iam_role.this.arn
  handler       = "app_client_count.lambda_handler"
  runtime       = "python3.11"
  timeout       = var.lambda_timeout_seconds

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      USER_POOL_ID     = var.user_pool_id
      ENVIRONMENT      = var.environment
      METRIC_NAMESPACE = var.metric_namespace
      METRIC_NAME      = var.metric_name
    }
  }

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.lambda.name
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/trade-tariff-identity-cognito-app-client-count-${var.environment}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "trade-tariff-identity-app-client-count-${var.environment}"
  description         = "Publish Cognito identity pool app client count custom metric"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "schedule" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "trade-tariff-identity-app-client-count-${var.environment}"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

resource "aws_cloudwatch_metric_alarm" "app_client_count" {
  alarm_name          = "trade-tariff-identity-cognito-app-client-count-${var.environment}"
  alarm_description   = "Identity Cognito user pool app clients >= ${var.alarm_threshold}. Mitigate via Service Quota increase and/or cleanup of stale credentials clients."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = var.metric_name
  namespace           = var.metric_namespace
  period              = 3600
  statistic           = "Maximum"
  threshold           = var.alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    UserPoolId  = var.user_pool_id
    Environment = var.environment
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}
