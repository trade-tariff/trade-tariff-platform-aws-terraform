mock_provider "aws" {
  override_data {
    target = data.aws_caller_identity.this
    values = {
      account_id = "123456789012"
    }
  }

  override_data {
    target = data.aws_region.this
    values = {
      region = "eu-west-2"
    }
  }
}

variables {
  alb_name              = "trade-tariff-alb-development"
  alb_security_group_id = "sg-00000000000000000"
  certificate_arn       = "arn:aws:acm:eu-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  public_subnet_ids     = ["subnet-00000000000000000", "subnet-11111111111111111"]
  vpc_id                = "vpc-00000000000000000"
  domain_name           = "dev.trade-tariff.service.gov.uk"

  custom_header = {
    name  = "X-Origin-Verify"
    value = "test-secret"
  }

  services = {
    frontend = {
      healthcheck_path = "/healthcheckz"
      priority         = 10
    }
  }
}

run "has_no_tags_by_default" {
  command = plan

  assert {
    condition     = length(aws_lb.application_load_balancer.tags) == 0
    error_message = "The load balancer must have no module tags when the caller gives none."
  }
}

run "tags_the_load_balancer_and_the_access_log_bucket" {
  command = plan

  variables {
    enable_access_logs = true
    tags               = { Component = "shared" }
  }

  assert {
    condition     = aws_lb.application_load_balancer.tags == tomap({ Component = "shared" })
    error_message = "The load balancer must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_s3_bucket.access_logs[0].tags == tomap({ Component = "shared" })
    error_message = "The access log bucket must carry the tags that the caller gives."
  }
}
