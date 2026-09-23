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

run "builds_engine_version_from_cluster_version" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.engine_version == "OpenSearch_3.5"
    error_message = "The engine version must be OpenSearch_ followed by cluster_version."
  }
}

run "omits_dedicated_master_settings_when_disabled" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].dedicated_master_enabled == false
    error_message = "Dedicated master nodes must be disabled when master_instance_enabled is false."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].dedicated_master_count == null
    error_message = "dedicated_master_count must not be sent when dedicated masters are disabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].dedicated_master_type == null
    error_message = "dedicated_master_type must not be sent when dedicated masters are disabled."
  }
}

run "sets_dedicated_master_settings_when_enabled" {
  command = plan

  variables {
    master_instance_enabled = true
    master_instance_count   = 3
    master_instance_type    = "m6g.large.search"
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].dedicated_master_enabled == true
    error_message = "Dedicated master nodes must be enabled when master_instance_enabled is true."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].dedicated_master_count == 3
    error_message = "dedicated_master_count must be master_instance_count when dedicated masters are enabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].dedicated_master_type == "m6g.large.search"
    error_message = "dedicated_master_type must be master_instance_type when dedicated masters are enabled."
  }
}

run "omits_warm_settings_when_disabled" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].warm_enabled == false
    error_message = "UltraWarm nodes must be disabled when warm_instance_enabled is false."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].warm_count == null
    error_message = "warm_count must not be sent when UltraWarm is disabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].warm_type == null
    error_message = "warm_type must not be sent when UltraWarm is disabled."
  }
}

run "sets_warm_settings_when_enabled" {
  command = plan

  variables {
    master_instance_enabled = true
    warm_instance_enabled   = true
    warm_instance_count     = 2
    warm_instance_type      = "ultrawarm1.medium.search"
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].warm_enabled == true
    error_message = "UltraWarm nodes must be enabled when warm_instance_enabled is true."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].warm_count == 2
    error_message = "warm_count must be warm_instance_count when UltraWarm is enabled."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].warm_type == "ultrawarm1.medium.search"
    error_message = "warm_type must be warm_instance_type when UltraWarm is enabled."
  }
}

run "spreads_nodes_across_availability_zones_by_default" {
  command = plan

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].zone_awareness_enabled == true
    error_message = "Zone awareness must be enabled when availability_zones is more than 1."
  }

  assert {
    condition     = length(aws_opensearch_domain.opensearch.cluster_config[0].zone_awareness_config) == 1
    error_message = "One zone_awareness_config block must be set when availability_zones is more than 1."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].zone_awareness_config[0].availability_zone_count == 3
    error_message = "availability_zone_count must be availability_zones."
  }
}

run "disables_zone_awareness_for_one_availability_zone" {
  command = plan

  variables {
    availability_zones = 1
    instance_count     = 1
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.cluster_config[0].zone_awareness_enabled == false
    error_message = "Zone awareness must be disabled when availability_zones is 1."
  }

  assert {
    condition     = length(aws_opensearch_domain.opensearch.cluster_config[0].zone_awareness_config) == 0
    error_message = "No zone_awareness_config block must be set when availability_zones is 1."
  }
}
