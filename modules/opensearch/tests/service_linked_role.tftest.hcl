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

run "creates_no_service_linked_role_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_service_linked_role.opensearch) == 0
    error_message = "No service-linked role must be created when create_service_role is false."
  }
}

run "creates_the_opensearch_service_linked_role_when_asked" {
  command = plan

  variables {
    create_service_role = true
  }

  assert {
    condition     = length(aws_iam_service_linked_role.opensearch) == 1
    error_message = "One service-linked role must be created when create_service_role is true."
  }

  assert {
    condition     = aws_iam_service_linked_role.opensearch[0].aws_service_name == "opensearchservice.amazonaws.com"
    error_message = "The service-linked role must be for the OpenSearch service."
  }
}
