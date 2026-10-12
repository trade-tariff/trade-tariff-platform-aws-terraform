mock_provider "aws" {
  override_data {
    target = data.aws_caller_identity.current
    values = {
      account_id = "123456789012"
    }
  }

  override_data {
    target = data.aws_region.current
    values = {
      region = "eu-west-2"
    }
  }

  override_data {
    target = data.aws_route53_zone.opensearch
    values = {
      id   = "Z00000000000000000000"
      name = "dev.trade-tariff.service.gov.uk"
    }
  }

  # Mock data sources return a random string for json. The resources
  # reject that at plan, so give them a valid (empty) policy document.
  override_data {
    target = data.aws_iam_policy_document.access_policy
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.opensearch_log_publishing
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

mock_provider "random" {}

variables {
  cluster_name    = "test-search"
  cluster_domain  = "dev.trade-tariff.service.gov.uk"
  cluster_version = "3.5"
  ssm_secret_name = "/development/ELASTICSEARCH_URL"

  master_instance_enabled = false
  warm_instance_enabled   = false
  instance_count          = 3
  instance_type           = "m6g.large.search"
}

run "has_no_tags_on_the_log_groups_by_default" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_log_group.opensearch_application_logs.tags) == 0 && length(aws_cloudwatch_log_group.opensearch_audit_logs.tags) == 0
    error_message = "The log groups must have no module tags when the caller gives none."
  }
}

run "tags_both_log_groups_with_the_given_tags" {
  command = plan

  variables {
    tags = { Component = "backend" }
  }

  assert {
    condition     = aws_cloudwatch_log_group.opensearch_application_logs.tags == tomap({ Component = "backend" })
    error_message = "The application log group must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_cloudwatch_log_group.opensearch_audit_logs.tags == tomap({ Component = "backend" })
    error_message = "The audit log group must carry the tags that the caller gives."
  }
}
