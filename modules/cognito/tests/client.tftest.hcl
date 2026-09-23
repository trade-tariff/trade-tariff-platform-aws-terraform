mock_provider "aws" {}
mock_provider "null" {}

variables {
  pool_name   = "test-pool"
  client_name = "test-client"
}

# The branch where client_name is null cannot be tested. outputs.tf reads
# aws_cognito_user_pool_client.this[0] with no guard, so the plan fails with
# "Invalid index". See the report for this bug.
run "creates_client_when_name_is_given" {
  command = plan

  assert {
    condition     = length(aws_cognito_user_pool_client.this) == 1
    error_message = "A client must be created when client_name is set."
  }
}

run "sends_no_oauth_scopes_when_oauth_is_not_allowed" {
  command = plan

  variables {
    client_oauth_flow_allowed = false
    client_oauth_scopes       = ["openid", "email"]
  }

  assert {
    condition     = length(aws_cognito_user_pool_client.this[0].allowed_oauth_scopes) == 0
    error_message = "No OAuth scopes must be sent when client_oauth_flow_allowed is false."
  }
}

run "sends_oauth_scopes_when_oauth_is_allowed" {
  command = plan

  variables {
    client_oauth_flow_allowed = true
    client_oauth_grant_types  = ["code"]
    client_oauth_scopes       = ["openid", "email"]
    client_callback_urls      = ["https://www.example.com/callback"]
    client_identity_providers = ["COGNITO"]
  }

  assert {
    condition     = toset(aws_cognito_user_pool_client.this[0].allowed_oauth_scopes) == toset(["openid", "email"])
    error_message = "The given OAuth scopes must be sent when client_oauth_flow_allowed is true."
  }
}

run "hides_user_existence_errors_by_default" {
  command = plan

  assert {
    condition     = aws_cognito_user_pool_client.this[0].prevent_user_existence_errors == "ENABLED"
    error_message = "prevent_user_existence_errors must be ENABLED by default."
  }
}

run "shows_user_existence_errors_when_disabled" {
  command = plan

  variables {
    client_prevent_user_existence_errors = false
  }

  assert {
    condition     = aws_cognito_user_pool_client.this[0].prevent_user_existence_errors == "LEGACY"
    error_message = "prevent_user_existence_errors must be LEGACY when client_prevent_user_existence_errors is false."
  }
}

run "omits_refresh_token_rotation_by_default" {
  command = plan

  assert {
    condition     = length(aws_cognito_user_pool_client.this[0].refresh_token_rotation) == 0
    error_message = "No refresh token rotation must be set by default."
  }
}

run "enables_refresh_token_rotation_when_asked" {
  command = plan

  variables {
    client_enable_refresh_token_rotation = true
  }

  assert {
    condition     = aws_cognito_user_pool_client.this[0].refresh_token_rotation[0].feature == "ENABLED"
    error_message = "Refresh token rotation must be ENABLED when client_enable_refresh_token_rotation is true."
  }

  assert {
    condition     = aws_cognito_user_pool_client.this[0].refresh_token_rotation[0].retry_grace_period_seconds == 0
    error_message = "Refresh token rotation must not allow a retry grace period."
  }
}

run "fills_token_validity_defaults_for_missing_tokens" {
  command = plan

  variables {
    client_token_validity = {
      refresh_token = {
        length = 30
        units  = "days"
      }
    }
  }

  assert {
    condition     = aws_cognito_user_pool_client.this[0].access_token_validity == 1 && aws_cognito_user_pool_client.this[0].token_validity_units[0].access_token == "hours"
    error_message = "The access token must default to 1 hour when not given."
  }

  assert {
    condition     = aws_cognito_user_pool_client.this[0].id_token_validity == 1 && aws_cognito_user_pool_client.this[0].token_validity_units[0].id_token == "hours"
    error_message = "The ID token must default to 1 hour when not given."
  }

  assert {
    condition     = aws_cognito_user_pool_client.this[0].refresh_token_validity == 30 && aws_cognito_user_pool_client.this[0].token_validity_units[0].refresh_token == "days"
    error_message = "The refresh token must use the given length and units."
  }
}
