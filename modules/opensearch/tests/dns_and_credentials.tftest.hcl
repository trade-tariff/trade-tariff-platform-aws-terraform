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

run "points_a_cname_at_the_domain_endpoint" {
  command = plan

  override_resource {
    target          = aws_opensearch_domain.opensearch
    override_during = plan
    values = {
      endpoint = "search-test-search-abc123.eu-west-2.es.amazonaws.com"
    }
  }

  assert {
    condition     = aws_route53_record.opensearch.zone_id == "Z00000000000000000000"
    error_message = "The DNS record must be in the cluster_domain hosted zone."
  }

  assert {
    condition     = aws_route53_record.opensearch.name == "test-search" && aws_route53_record.opensearch.type == "CNAME"
    error_message = "The DNS record must be a CNAME named after the cluster."
  }

  assert {
    condition     = aws_route53_record.opensearch.records == toset(["search-test-search-abc123.eu-west-2.es.amazonaws.com"])
    error_message = "The DNS record must point at the OpenSearch domain endpoint."
  }
}

run "stores_the_connection_url_as_a_secure_string" {
  command = plan

  variables {
    create_master_user   = false
    master_user_username = "given-user"
    master_user_password = "Given-Passw0rd!"
  }

  override_resource {
    target          = aws_route53_record.opensearch
    override_during = plan
    values = {
      fqdn = "test-search.dev.trade-tariff.service.gov.uk"
    }
  }

  assert {
    condition     = aws_ssm_parameter.opensearch_url.name == "/development/ELASTICSEARCH_URL"
    error_message = "The SSM parameter must use the name that the caller gives."
  }

  assert {
    condition     = aws_ssm_parameter.opensearch_url.type == "SecureString"
    error_message = "The SSM parameter must be a SecureString because it holds the master password."
  }

  assert {
    condition     = nonsensitive(aws_ssm_parameter.opensearch_url.value) == format("https://%s:%s@%s", "given-user", "Given-Passw0rd!", "test-search.dev.trade-tariff.service.gov.uk")
    error_message = "The SSM parameter must hold an HTTPS URL with the master user credentials and the custom DNS name."
  }
}
