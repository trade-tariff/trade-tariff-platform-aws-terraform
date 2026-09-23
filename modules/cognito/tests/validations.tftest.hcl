mock_provider "aws" {}
mock_provider "null" {}

variables {
  pool_name = "test-pool"

  # outputs.tf reads aws_cognito_user_pool_client.this[0] with no guard, so
  # every run must create the client. See the report for this bug.
  client_name = "test-client"
}

run "accepts_default_inputs" {
  command = plan
}

run "rejects_unknown_mfa_configuration" {
  command = plan

  variables {
    mfa_configuration = "REQUIRED"
  }

  expect_failures = [
    var.mfa_configuration,
  ]
}

run "accepts_mfa_configuration_on" {
  command = plan

  variables {
    mfa_configuration = "ON"
  }

  assert {
    condition     = aws_cognito_user_pool.this.mfa_configuration == "ON"
    error_message = "mfa_configuration ON must be accepted."
  }
}

run "rejects_sms_authentication_message_without_placeholder" {
  command = plan

  variables {
    sms_authentication_message = "Your temporary password is ready."
  }

  expect_failures = [
    var.sms_authentication_message,
  ]
}

run "accepts_sms_authentication_message_with_placeholder" {
  command = plan

  variables {
    sms_authentication_message = "{####} is your code."
  }

  assert {
    condition     = aws_cognito_user_pool.this.sms_authentication_message == "{####} is your code."
    error_message = "An SMS authentication message with the {####} placeholder must be accepted."
  }
}

run "rejects_unknown_user_pool_tier" {
  command = plan

  variables {
    user_pool_tier = "ENTERPRISE"
  }

  expect_failures = [
    var.user_pool_tier,
  ]
}

run "accepts_user_pool_tier_plus" {
  command = plan

  variables {
    user_pool_tier = "PLUS"
  }

  assert {
    condition     = aws_cognito_user_pool.this.user_pool_tier == "PLUS"
    error_message = "user_pool_tier PLUS must be accepted."
  }
}
