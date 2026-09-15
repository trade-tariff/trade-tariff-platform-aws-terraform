provider "aws" {
  region                      = "eu-west-2"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "access_log_format_records_the_end_user_client_id" {
  command = plan

  variables {
    environment               = "test"
    domain_name               = "example.test"
    validated_certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
    zone_id                   = "Z0000000000000000000"
    security_group_ids        = ["sg-00000000000000000"]
    private_subnet_ids        = ["subnet-00000000000000000", "subnet-11111111111111111"]
    lb_arn                    = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/app/test/0000000000000000"
    alb_secret_header         = ["X-Origin-Secret", "test-secret"]
    access_logging_enabled    = true
    cloudwatch_role_arn       = "arn:aws:iam::123456789012:role/serverlessApiGatewayCloudWatchRole"
  }

  assert {
    condition     = jsondecode(aws_api_gateway_stage.this.access_log_settings[0].format)["clientId"] == "$context.authorizer.client_id"
    error_message = "Access logs must record the authorizer's client_id, so end users stay identifiable once MCP traffic shares one API key."
  }

  assert {
    condition     = jsondecode(aws_api_gateway_stage.this.access_log_settings[0].format)["apiKeyId"] == "$context.identity.apiKeyId"
    error_message = "apiKeyId must still be recorded."
  }
}
