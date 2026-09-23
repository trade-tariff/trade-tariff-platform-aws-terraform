mock_provider "aws" {}
mock_provider "null" {}

variables {
  pool_name = "test-pool"

  # outputs.tf reads aws_cognito_user_pool_client.this[0] with no guard, so
  # every run must create the client. See the report for this bug.
  client_name = "test-client"
}

run "creates_no_optional_resources_by_default" {
  command = plan

  assert {
    condition     = length(aws_cognito_user_pool_domain.this) == 0
    error_message = "No domain must be created when domain is null."
  }

  assert {
    condition     = length(aws_cognito_resource_server.this) == 0
    error_message = "No resource server must be created when resource_server_name is null."
  }

  assert {
    condition     = length(aws_cognito_user_group.groups) == 0
    error_message = "No user groups must be created when user_groups is empty."
  }
}

run "creates_domain_when_given" {
  command = plan

  variables {
    domain = "test-pool-domain"
  }

  assert {
    condition     = length(aws_cognito_user_pool_domain.this) == 1
    error_message = "A domain must be created when domain is set."
  }
}

run "creates_resource_server_with_scopes" {
  command = plan

  variables {
    resource_server_name       = "test-api"
    resource_server_identifier = "https://api.example.com"
    resource_server_scopes = [
      { scope_name = "read", scope_description = "Read access" },
      { scope_name = "write", scope_description = "Write access" },
    ]
  }

  assert {
    condition     = length(aws_cognito_resource_server.this) == 1
    error_message = "A resource server must be created when resource_server_name is set."
  }

  assert {
    condition = toset([
      for scope in aws_cognito_resource_server.this[0].scope : scope.scope_name
    ]) == toset(["read", "write"])
    error_message = "The resource server must have one scope for each given scope."
  }
}

run "creates_user_groups_keyed_by_name" {
  command = plan

  variables {
    user_groups = [
      {
        name        = "admins"
        description = "Administrators"
        precedence  = 1
        role_arn    = "arn:aws:iam::123456789012:role/admins"
      },
      {
        name = "readers"
      },
    ]
  }

  assert {
    condition     = toset(keys(aws_cognito_user_group.groups)) == toset(["admins", "readers"])
    error_message = "One user group must be created for each given group, keyed by name."
  }

  assert {
    condition     = aws_cognito_user_group.groups["admins"].precedence == 1 && aws_cognito_user_group.groups["admins"].role_arn == "arn:aws:iam::123456789012:role/admins"
    error_message = "A user group must keep its given precedence and role ARN."
  }

  assert {
    condition     = aws_cognito_user_group.groups["readers"].role_arn == null
    error_message = "A user group without a role ARN must have no role."
  }

  assert {
    condition     = output.user_groups["admins"].description == "Administrators"
    error_message = "The user_groups output must expose each group's details by name."
  }
}
