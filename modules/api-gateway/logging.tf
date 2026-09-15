resource "aws_cloudwatch_log_group" "access_logs" {
  count             = var.access_logging_enabled ? 1 : 0
  name              = "/aws/apigateway/api-${var.environment}/access-logs"
  retention_in_days = var.access_log_retention_days
}

# Account-level singleton (one per AWS account/region). Safe to declare here
# because each environment (development/staging/production) is its own AWS
# account. Reuses the pre-existing serverlessApiGatewayCloudWatchRole
# (aws_iam_role.apigw_cloudwatch_logs in each environment's iam-roles.tf)
resource "aws_api_gateway_account" "this" {
  count               = var.access_logging_enabled ? 1 : 0
  cloudwatch_role_arn = var.cloudwatch_role_arn
}

# Example query for the "active API consumers" acceptance criterion.
# Apply a 30/90-day time range when running it in the Logs Insights console.
resource "aws_cloudwatch_query_definition" "active_api_keys" {
  count           = var.access_logging_enabled ? 1 : 0
  name            = "api-${var.environment}/active-api-keys"
  log_group_names = [aws_cloudwatch_log_group.access_logs[0].name]

  # clientId (from $context.authorizer.client_id) is only populated when the
  # Lambda authorizer ran; other paths carry API Gateway's "-" placeholder
  # there instead, but still have apiKeyId when a usage-plan key was
  # presented. `parse` only sets realClientId on rows whose clientId doesn't
  # start with "-" -- it leaves the field null (not "-" or "") on the rest --
  # so `coalesce` can fall back to apiKeyId for exactly the rows the
  # authorizer never touched, instead of dropping them from this view.
  query_string = <<-EOT
    fields @timestamp, clientId, apiKeyId, status
    | parse clientId /^(?<realClientId>[^-].*)$/
    | fields coalesce(realClientId, apiKeyId) as consumer
    | filter consumer != "-" and consumer != ""
    | stats count(*) as requests by consumer
    | sort requests desc
  EOT
}
