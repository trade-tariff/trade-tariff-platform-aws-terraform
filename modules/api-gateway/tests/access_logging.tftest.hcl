mock_provider "aws" {}

variables {
  environment               = "test"
  domain_name               = "example.test"
  validated_certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  zone_id                   = "Z0000000000000000000"
  security_group_ids        = ["sg-00000000000000000"]
  private_subnet_ids        = ["subnet-00000000000000000", "subnet-11111111111111111"]
  lb_arn                    = "arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/app/test/0000000000000000"
  alb_secret_header         = ["X-Origin-Secret", "test-secret"]
}

run "no_access_logging_resources_when_disabled" {
  command = plan

  assert {
    condition = alltrue([
      length(aws_cloudwatch_log_group.access_logs) == 0,
      length(aws_api_gateway_account.this) == 0,
      length(aws_cloudwatch_query_definition.active_api_keys) == 0,
    ])
    error_message = "No log group, account setting or query definition must be created when access logging is disabled."
  }

  assert {
    condition     = length(aws_api_gateway_stage.this.access_log_settings) == 0
    error_message = "The stage must not send access logs when access logging is disabled."
  }

  assert {
    condition     = output.access_log_group_name == null
    error_message = "access_log_group_name must be null when access logging is disabled."
  }
}

run "access_logging_resources_are_created_when_enabled" {
  command = plan

  variables {
    access_logging_enabled    = true
    access_log_retention_days = 30
    cloudwatch_role_arn       = "arn:aws:iam::123456789012:role/serverlessApiGatewayCloudWatchRole"
  }

  assert {
    condition = alltrue([
      length(aws_cloudwatch_log_group.access_logs) == 1,
      length(aws_api_gateway_account.this) == 1,
      length(aws_cloudwatch_query_definition.active_api_keys) == 1,
    ])
    error_message = "A log group, account setting and query definition must be created when access logging is enabled."
  }

  assert {
    condition     = aws_cloudwatch_log_group.access_logs[0].name == "/aws/apigateway/api-test/access-logs"
    error_message = "The access log group name must be /aws/apigateway/api-<environment>/access-logs."
  }

  assert {
    condition     = aws_cloudwatch_log_group.access_logs[0].retention_in_days == 30
    error_message = "The access log group must use access_log_retention_days."
  }

  assert {
    condition     = output.access_log_group_name == "/aws/apigateway/api-test/access-logs"
    error_message = "access_log_group_name must be the access log group name when access logging is enabled."
  }

  assert {
    condition     = aws_cloudwatch_query_definition.active_api_keys[0].log_group_names == tolist(["/aws/apigateway/api-test/access-logs"])
    error_message = "The active API keys query must read the access log group."
  }
}

run "stage_access_log_format_records_the_api_key" {
  command = plan

  variables {
    access_logging_enabled = true
    cloudwatch_role_arn    = "arn:aws:iam::123456789012:role/serverlessApiGatewayCloudWatchRole"
  }

  assert {
    condition     = length(aws_api_gateway_stage.this.access_log_settings) == 1
    error_message = "The stage must send access logs when access logging is enabled."
  }

  assert {
    condition     = jsondecode(aws_api_gateway_stage.this.access_log_settings[0].format).apiKeyId == "$context.identity.apiKeyId"
    error_message = "The access log format must record the API key ID, so active consumers can be found."
  }

  assert {
    condition = alltrue([
      for field in ["requestId", "requestTime", "sourceIp", "httpMethod", "path", "status", "integrationStatus", "responseLength"] :
      contains(keys(jsondecode(aws_api_gateway_stage.this.access_log_settings[0].format)), field)
    ])
    error_message = "The access log format must include the request, status and size fields."
  }
}
