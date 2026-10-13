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

run "has_no_tags_by_default" {
  command = plan

  assert {
    condition     = length(aws_api_gateway_rest_api.this.tags) == 0
    error_message = "The REST API must have no module tags when the caller gives none."
  }
}

run "tags_every_taggable_resource" {
  command = plan

  variables {
    access_logging_enabled    = true
    access_log_retention_days = 30
    cloudwatch_role_arn       = "arn:aws:iam::123456789012:role/serverlessApiGatewayCloudWatchRole"
    tags                      = { Component = "shared" }
  }

  assert {
    condition = alltrue([
      aws_api_gateway_rest_api.this.tags == tomap({ Component = "shared" }),
      aws_api_gateway_stage.this.tags == tomap({ Component = "shared" }),
      aws_api_gateway_domain_name.api.tags == tomap({ Component = "shared" }),
      aws_apigatewayv2_vpc_link.this.tags == tomap({ Component = "shared" }),
    ])
    error_message = "The REST API, stage, domain name and VPC link must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_cloudwatch_log_group.access_logs[0].tags == tomap({ Component = "shared" })
    error_message = "The access log group must carry the tags that the caller gives."
  }
}
