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

run "creates_a_random_master_user_by_default" {
  command = plan

  override_resource {
    target          = random_string.master_user_username
    override_during = plan
    values = {
      result = "randuser"
    }
  }

  override_resource {
    target          = random_password.master_user_password
    override_during = plan
    values = {
      result = "Rand0m!Passw0rd_"
    }
  }

  assert {
    condition     = length(random_string.master_user_username) == 1 && length(random_password.master_user_password) == 1
    error_message = "A random username and password must be created when create_master_user is true."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.advanced_security_options[0].master_user_options[0].master_user_name == "randuser"
    error_message = "The master user name must be the random username."
  }

  assert {
    condition     = nonsensitive(aws_opensearch_domain.opensearch.advanced_security_options[0].master_user_options[0].master_user_password == "Rand0m!Passw0rd_")
    error_message = "The master user password must be the random password."
  }
}

run "random_password_meets_complexity_rules" {
  command = plan

  assert {
    condition     = random_password.master_user_password[0].length >= 8 && random_password.master_user_password[0].special == true
    error_message = "The random password must be at least 8 characters and include special characters."
  }

  assert {
    condition = alltrue([
      random_password.master_user_password[0].min_upper >= 1,
      random_password.master_user_password[0].min_lower >= 1,
      random_password.master_user_password[0].min_numeric >= 1,
      random_password.master_user_password[0].min_special >= 1,
    ])
    error_message = "The random password must include at least one upper, lower, numeric and special character, as OpenSearch requires."
  }

  # The password goes into a URL (scheme, user, password, host) that the
  # module stores in SSM, so it must only use URL-safe special characters.
  assert {
    condition     = random_password.master_user_password[0].override_special == "!_$"
    error_message = "The random password must only use the URL-safe special characters !, _ and $."
  }
}

run "uses_the_given_master_user_when_not_creating_one" {
  command = plan

  variables {
    create_master_user   = false
    master_user_username = "given-user"
    master_user_password = "Given-Passw0rd!"
  }

  assert {
    condition     = length(random_string.master_user_username) == 0 && length(random_password.master_user_password) == 0
    error_message = "No random username or password must be created when create_master_user is false."
  }

  assert {
    condition     = aws_opensearch_domain.opensearch.advanced_security_options[0].master_user_options[0].master_user_name == "given-user"
    error_message = "The master user name must be the username that the caller gives."
  }

  assert {
    condition     = nonsensitive(aws_opensearch_domain.opensearch.advanced_security_options[0].master_user_options[0].master_user_password == "Given-Passw0rd!")
    error_message = "The master user password must be the password that the caller gives."
  }
}
