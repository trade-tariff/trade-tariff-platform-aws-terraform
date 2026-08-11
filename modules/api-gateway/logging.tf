resource "aws_cloudwatch_log_group" "access_logs" {
  count             = var.access_logging_enabled ? 1 : 0
  name              = "/aws/apigateway/api-${var.environment}/access-logs"
  retention_in_days = var.access_log_retention_days
}

resource "aws_iam_role" "cloudwatch" {
  count = var.access_logging_enabled ? 1 : 0
  name  = "api-gateway-cloudwatch-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count      = var.access_logging_enabled ? 1 : 0
  role       = aws_iam_role.cloudwatch[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Account-level singleton (one per AWS account/region). Safe to declare here
# because each environment (development/staging/production) is its own AWS
# account.
resource "aws_api_gateway_account" "this" {
  count               = var.access_logging_enabled ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.cloudwatch[0].arn
}

# Example query for the "active API consumers" acceptance criterion.
# Apply a 30/90-day time range when running it in the Logs Insights console.
resource "aws_cloudwatch_query_definition" "active_api_keys" {
  count           = var.access_logging_enabled ? 1 : 0
  name            = "api-${var.environment}/active-api-keys"
  log_group_names = [aws_cloudwatch_log_group.access_logs[0].name]

  query_string = <<-EOT
    fields @timestamp, apiKeyId, status
    | filter apiKeyId != "-"
    | stats count(*) as requests by apiKeyId
    | sort requests desc
  EOT
}
