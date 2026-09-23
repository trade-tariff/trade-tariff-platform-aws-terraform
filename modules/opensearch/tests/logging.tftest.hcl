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

run "creates_application_and_audit_log_groups" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.opensearch_application_logs.name == "/aws/opensearch/test-search/application-logs"
    error_message = "The application log group name must include the cluster name."
  }

  assert {
    condition     = aws_cloudwatch_log_group.opensearch_audit_logs.name == "/aws/opensearch/test-search/audit-logs"
    error_message = "The audit log group name must include the cluster name."
  }

  assert {
    condition     = aws_cloudwatch_log_group.opensearch_application_logs.retention_in_days == 90 && aws_cloudwatch_log_group.opensearch_audit_logs.retention_in_days == 90
    error_message = "Both log groups must keep logs for 90 days."
  }
}

run "publishes_application_and_audit_logs" {
  command = plan

  override_resource {
    target          = aws_cloudwatch_log_group.opensearch_application_logs
    override_during = plan
    values = {
      arn = "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/opensearch/test-search/application-logs"
    }
  }

  override_resource {
    target          = aws_cloudwatch_log_group.opensearch_audit_logs
    override_during = plan
    values = {
      arn = "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/opensearch/test-search/audit-logs"
    }
  }

  assert {
    condition = {
      for option in aws_opensearch_domain.opensearch.log_publishing_options :
      option.log_type => { enabled = option.enabled, log_group = option.cloudwatch_log_group_arn }
      } == {
      ES_APPLICATION_LOGS = {
        enabled   = true
        log_group = "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/opensearch/test-search/application-logs"
      }
      AUDIT_LOGS = {
        enabled   = true
        log_group = "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/opensearch/test-search/audit-logs"
      }
    }
    error_message = "Application and audit logs must be enabled and sent to their own log groups."
  }

  assert {
    condition = data.aws_iam_policy_document.opensearch_log_publishing.statement[0].resources == toset([
      "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/opensearch/test-search/application-logs:*",
      "arn:aws:logs:eu-west-2:123456789012:log-group:/aws/opensearch/test-search/audit-logs:*",
    ])
    error_message = "The log publishing policy must be scoped to the two OpenSearch log groups."
  }
}

run "only_opensearch_can_write_to_the_log_groups" {
  command = plan

  assert {
    condition     = length(data.aws_iam_policy_document.opensearch_log_publishing.statement) == 1
    error_message = "The log publishing policy must have exactly one statement."
  }

  assert {
    condition     = data.aws_iam_policy_document.opensearch_log_publishing.statement[0].actions == toset(["logs:PutLogEvents", "logs:CreateLogStream"])
    error_message = "The log publishing policy must allow only logs:PutLogEvents and logs:CreateLogStream."
  }

  assert {
    condition = [
      for principal in data.aws_iam_policy_document.opensearch_log_publishing.statement[0].principals :
      { type = principal.type, identifiers = principal.identifiers }
      ] == [
      { type = "Service", identifiers = toset(["es.amazonaws.com"]) }
    ]
    error_message = "Only the es.amazonaws.com service principal must be able to write to the log groups."
  }

  assert {
    condition     = aws_cloudwatch_log_resource_policy.opensearch_log_publishing.policy_name == "test-search-opensearch-log-publishing"
    error_message = "The log resource policy name must include the cluster name."
  }
}
