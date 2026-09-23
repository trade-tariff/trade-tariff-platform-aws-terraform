mock_provider "aws" {}
mock_provider "null" {}

variables {
  pool_name = "test-pool"

  # outputs.tf reads aws_cognito_user_pool_client.this[0] with no guard, so
  # every run must create the client. See the report for this bug.
  client_name = "test-client"
}

run "protects_pool_from_deletion_by_default" {
  command = plan

  assert {
    condition     = aws_cognito_user_pool.this.deletion_protection == "ACTIVE"
    error_message = "deletion_protection must be ACTIVE by default."
  }
}

run "allows_deletion_when_prevent_deletion_is_false" {
  command = plan

  variables {
    prevent_deletion = false
  }

  assert {
    condition     = aws_cognito_user_pool.this.deletion_protection == "INACTIVE"
    error_message = "deletion_protection must be INACTIVE when prevent_deletion is false."
  }
}

run "only_admins_create_users_by_default" {
  command = plan

  assert {
    condition     = aws_cognito_user_pool.this.admin_create_user_config[0].allow_admin_create_user_only == true
    error_message = "Only administrators must be able to create users by default."
  }
}

run "allows_self_registration_when_enabled" {
  command = plan

  variables {
    allow_user_registration = true
  }

  assert {
    condition     = aws_cognito_user_pool.this.admin_create_user_config[0].allow_admin_create_user_only == false
    error_message = "Users must be able to sign up when allow_user_registration is true."
  }
}

run "omits_invite_message_template_when_null" {
  command = plan

  variables {
    invite_message_template = null
  }

  assert {
    condition     = length(aws_cognito_user_pool.this.admin_create_user_config[0].invite_message_template) == 0
    error_message = "No invite message template must be set when invite_message_template is null."
  }
}

run "uses_cognito_email_by_default" {
  command = plan

  assert {
    condition     = aws_cognito_user_pool.this.email_configuration[0].email_sending_account == "COGNITO_DEFAULT"
    error_message = "email_sending_account must be COGNITO_DEFAULT when no SES configuration set is given."
  }
}

run "uses_developer_email_with_ses_configuration_set" {
  command = plan

  variables {
    email_configuration_set = "test-configuration-set"
    from_email_address      = "Trade Tariff <no-reply@example.com>"
    ses_identity_source_arn = "arn:aws:ses:eu-west-2:123456789012:identity/example.com"
  }

  assert {
    condition     = aws_cognito_user_pool.this.email_configuration[0].email_sending_account == "DEVELOPER"
    error_message = "email_sending_account must be DEVELOPER when an SES configuration set is given."
  }
}

run "sets_account_recovery_from_mechanisms" {
  command = plan

  variables {
    recovery_mechanisms = [
      { name = "verified_email", priority = 1 },
      { name = "verified_phone_number", priority = 2 },
    ]
  }

  assert {
    condition     = length(aws_cognito_user_pool.this.account_recovery_setting) == 1
    error_message = "An account recovery setting must be set when recovery mechanisms are given."
  }

  assert {
    condition = toset([
      for mechanism in aws_cognito_user_pool.this.account_recovery_setting[0].recovery_mechanism : "${mechanism.name}:${mechanism.priority}"
    ]) == toset(["verified_email:1", "verified_phone_number:2"])
    error_message = "Each recovery mechanism must keep its name and priority."
  }
}

run "omits_account_recovery_without_mechanisms" {
  command = plan

  variables {
    recovery_mechanisms = []
  }

  assert {
    condition     = length(aws_cognito_user_pool.this.account_recovery_setting) == 0
    error_message = "No account recovery setting must be set when recovery_mechanisms is empty."
  }
}

run "enables_software_mfa_token_by_default" {
  command = plan

  assert {
    condition     = length(aws_cognito_user_pool.this.software_token_mfa_configuration) == 1
    error_message = "Software token MFA configuration must be set by default."
  }

  assert {
    condition     = aws_cognito_user_pool.this.software_token_mfa_configuration[0].enabled == true
    error_message = "Software token MFA must be enabled by default."
  }
}

run "omits_software_mfa_token_when_disabled" {
  command = plan

  variables {
    allow_software_mfa_token = false
    mfa_configuration        = "OFF"
  }

  assert {
    condition     = length(aws_cognito_user_pool.this.software_token_mfa_configuration) == 0
    error_message = "No software token MFA configuration must be set when allow_software_mfa_token is false."
  }
}

run "sets_strong_password_policy_by_default" {
  command = plan

  assert {
    condition     = aws_cognito_user_pool.this.password_policy[0].minimum_length == 12
    error_message = "The default password policy must require at least 12 characters."
  }

  assert {
    condition = alltrue([
      aws_cognito_user_pool.this.password_policy[0].require_lowercase,
      aws_cognito_user_pool.this.password_policy[0].require_numbers,
      aws_cognito_user_pool.this.password_policy[0].require_symbols,
      aws_cognito_user_pool.this.password_policy[0].require_uppercase,
    ])
    error_message = "The default password policy must require lowercase, numbers, symbols and uppercase."
  }
}

run "sets_sign_in_policy_when_first_auth_factors_given" {
  command = plan

  variables {
    user_pool_tier             = "ESSENTIALS"
    allowed_first_auth_factors = ["PASSWORD", "EMAIL_OTP"]
  }

  assert {
    condition     = length(aws_cognito_user_pool.this.sign_in_policy) == 1
    error_message = "A sign in policy must be set when allowed_first_auth_factors is given."
  }

  assert {
    condition     = toset(aws_cognito_user_pool.this.sign_in_policy[0].allowed_first_auth_factors) == toset(["PASSWORD", "EMAIL_OTP"])
    error_message = "The sign in policy must use the given first auth factors."
  }
}

run "sets_custom_email_sender_when_given" {
  command = plan

  variables {
    lambda_kms_key_id = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
    lambda_custom_email_sender = {
      lambda_arn     = "arn:aws:lambda:eu-west-2:123456789012:function:custom-email-sender"
      lambda_version = "V1_0"
    }
  }

  assert {
    condition     = aws_cognito_user_pool.this.lambda_config[0].custom_email_sender[0].lambda_arn == "arn:aws:lambda:eu-west-2:123456789012:function:custom-email-sender"
    error_message = "The custom email sender must use the given Lambda ARN."
  }
}

run "omits_custom_email_sender_by_default" {
  command = plan

  assert {
    condition     = length(aws_cognito_user_pool.this.lambda_config[0].custom_email_sender) == 0
    error_message = "No custom email sender must be set by default."
  }
}
