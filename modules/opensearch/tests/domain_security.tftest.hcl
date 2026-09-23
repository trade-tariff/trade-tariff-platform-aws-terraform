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

run "encrypts_data_at_rest_and_between_nodes" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.encrypt_at_rest[0].enabled == true
    error_message = "Encryption at rest must be enabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.node_to_node_encryption[0].enabled == true
    error_message = "Node-to-node encryption must be enabled."
  }
}

run "uses_the_given_kms_key_for_encryption_at_rest" {
  command = plan

  variables {
    encrypt_kms_key_id = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.encrypt_at_rest[0].kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
    error_message = "Encryption at rest must use the KMS key that the caller gives."
  }
}

run "enforces_https_with_a_modern_tls_policy" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.domain_endpoint_options[0].enforce_https == true
    error_message = "The domain endpoint must enforce HTTPS."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.domain_endpoint_options[0].tls_security_policy == "Policy-Min-TLS-1-2-PFS-2023-10"
    error_message = "The domain endpoint must require TLS 1.2 or later with perfect forward secrecy."
  }
}

run "serves_a_custom_endpoint_under_the_hosted_zone" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.domain_endpoint_options[0].custom_endpoint_enabled == true
    error_message = "The custom endpoint must be enabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.domain_endpoint_options[0].custom_endpoint == "test-search.dev.trade-tariff.service.gov.uk"
    error_message = "The custom endpoint must be the cluster name under the hosted zone name."
  }

  assert {
    condition     = one(module.acm.distinct_domain_names) == "test-search.dev.trade-tariff.service.gov.uk"
    error_message = "The certificate must be issued for the custom endpoint name."
  }
}

run "requires_fine_grained_access_control" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.advanced_security_options[0].enabled == true
    error_message = "Fine-grained access control must be enabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.advanced_security_options[0].anonymous_auth_enabled == false
    error_message = "Anonymous access must be disabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.advanced_security_options[0].internal_user_database_enabled == true
    error_message = "The internal user database must be enabled so the master user can sign in."
  }
}

# The access policy allows every AWS principal. Fine-grained access control
# is the real guard. This run checks that the policy at least stays scoped
# to OpenSearch domains in this account and region.
run "access_policy_is_scoped_to_domains_in_this_account_and_region" {
  command = plan

  assert {
    condition     = length(data.aws_iam_policy_document.access_policy.statement) == 1
    error_message = "The access policy must have exactly one statement."
  }

  assert {
    condition     = data.aws_iam_policy_document.access_policy.statement[0].resources == toset(["arn:aws:es:eu-west-2:123456789012:domain/*"])
    error_message = "The access policy must be scoped to OpenSearch domains in the current account and region."
  }
}
