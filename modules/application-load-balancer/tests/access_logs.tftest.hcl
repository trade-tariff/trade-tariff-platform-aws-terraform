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

run "creates_no_log_bucket_when_access_logs_are_disabled" {
  command = plan

  assert {
    condition     = length(aws_s3_bucket.access_logs) == 0
    error_message = "No access log bucket must be created when access logs are disabled."
  }

  assert {
    condition     = length(aws_s3_bucket_policy.this) == 0
    error_message = "No access log bucket policy must be created when access logs are disabled."
  }

  assert {
    condition     = length(aws_lb.application_load_balancer.access_logs) == 0
    error_message = "The load balancer must have no access_logs block when access logs are disabled."
  }
}

run "creates_log_bucket_when_access_logs_are_enabled_without_a_bucket" {
  command = plan

  variables {
    enable_access_logs = true
    access_logs_prefix = "alb"
  }

  assert {
    condition     = length(aws_s3_bucket.access_logs) == 1
    error_message = "An access log bucket must be created when access logs are enabled and no bucket is given."
  }

  assert {
    condition     = aws_s3_bucket.access_logs[0].bucket == "trade-tariff-alb-development-access-logs-123456789012"
    error_message = "The access log bucket name must be <alb_name>-access-logs-<account_id>."
  }

  assert {
    condition     = length(aws_lb.application_load_balancer.access_logs) == 1
    error_message = "The load balancer must have an access_logs block when access logs are enabled."
  }

  assert {
    condition     = aws_lb.application_load_balancer.access_logs[0].enabled == true
    error_message = "Access logs must be enabled on the load balancer."
  }

  assert {
    condition     = aws_lb.application_load_balancer.access_logs[0].prefix == "alb"
    error_message = "The access log prefix must be set on the load balancer."
  }
}

run "blocks_all_public_access_to_the_created_log_bucket" {
  command = plan

  variables {
    enable_access_logs = true
  }

  assert {
    condition     = length(aws_s3_bucket_public_access_block.this) == 1
    error_message = "A public access block must be created for the access log bucket."
  }

  assert {
    condition = (
      aws_s3_bucket_public_access_block.this[0].block_public_acls == true &&
      aws_s3_bucket_public_access_block.this[0].block_public_policy == true &&
      aws_s3_bucket_public_access_block.this[0].ignore_public_acls == true &&
      aws_s3_bucket_public_access_block.this[0].restrict_public_buckets == true
    )
    error_message = "All four public access block settings must be true on the access log bucket."
  }
}

run "expires_access_logs_after_32_days" {
  command = plan

  variables {
    enable_access_logs = true
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 1
    error_message = "A lifecycle configuration must be created for the access log bucket."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[0].status == "Enabled"
    error_message = "The access log lifecycle rule must be enabled."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[0].expiration[0].days == 32
    error_message = "Access log objects must expire after 32 days."
  }
}

run "allows_only_the_regional_elb_account_to_write_logs" {
  command = plan

  variables {
    enable_access_logs = true
  }

  assert {
    condition     = length(aws_s3_bucket_policy.this) == 1
    error_message = "A bucket policy must be created for the access log bucket."
  }

  assert {
    condition     = data.aws_iam_policy_document.alb_logs_policy[0].statement[0].actions == toset(["s3:PutObject"])
    error_message = "The log bucket policy must only allow s3:PutObject."
  }

  assert {
    condition     = one(data.aws_iam_policy_document.alb_logs_policy[0].statement[0].principals).identifiers == toset(["arn:aws:iam::652711504416:root"])
    error_message = "The log bucket policy principal must be the ELB account for eu-west-2."
  }

  assert {
    condition     = one(data.aws_iam_policy_document.alb_logs_policy[0].statement[0].condition).values == tolist(["arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/*"])
    error_message = "The log bucket policy must only accept writes from load balancers in this account and region."
  }
}

run "uses_existing_bucket_when_one_is_given" {
  command = plan

  variables {
    enable_access_logs = true
    access_logs_bucket = "existing-access-logs-bucket"
  }

  assert {
    condition     = length(aws_s3_bucket.access_logs) == 0
    error_message = "No access log bucket must be created when the caller gives a bucket."
  }

  assert {
    condition     = length(aws_s3_bucket_policy.this) == 0
    error_message = "No bucket policy must be created when the caller gives a bucket."
  }

  assert {
    condition     = aws_lb.application_load_balancer.access_logs[0].bucket == "existing-access-logs-bucket"
    error_message = "The load balancer must send access logs to the bucket the caller gives."
  }
}
