resource "null_resource" "schema_checksum" {
  triggers = {
    schema = md5(jsonencode(var.schemata))
  }
}

resource "aws_cognito_user_pool" "this" {
  name = var.pool_name

  alias_attributes           = var.alias_attributes
  auto_verified_attributes   = var.auto_verified_attributes
  mfa_configuration          = var.mfa_configuration
  sms_authentication_message = var.sms_authentication_message
  username_attributes        = var.username_attributes

  dynamic "account_recovery_setting" {
    for_each = length(var.recovery_mechanisms) > 0 ? [true] : []
    content {
      dynamic "recovery_mechanism" {
        for_each = var.recovery_mechanisms
        content {
          name     = recovery_mechanism.value.name
          priority = recovery_mechanism.value.priority
        }
      }
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = var.allow_user_registration ? false : true
    dynamic "invite_message_template" {
      for_each = var.invite_message_template != null ? [var.invite_message_template] : []
      content {
        email_subject = invite_message_template.value.email_subject
        email_message = invite_message_template.value.email_message
        sms_message   = invite_message_template.value.sms_message
      }
    }
  }

  dynamic "device_configuration" {
    for_each = var.device_configuration != null ? [var.device_configuration] : []
    content {
      challenge_required_on_new_device      = device_configuration.value.challenge_required_on_new_device
      device_only_remembered_on_user_prompt = device_configuration.device_only_remembered_on_user_prompt
    }
  }

  email_configuration {
    configuration_set      = var.email_configuration_set
    email_sending_account  = local.email_sending_account
    from_email_address     = var.from_email_address
    reply_to_email_address = var.reply_to_email_address
    source_arn             = var.ses_identity_source_arn
  }

  lambda_config {
    create_auth_challenge          = var.lambda_create_auth_challenge_arn
    custom_message                 = var.lambda_custom_message
    define_auth_challenge          = var.lambda_define_auth_challenge
    post_authentication            = var.lambda_post_authentication
    post_confirmation              = var.lambda_post_confirmation
    pre_authentication             = var.lambda_pre_authentication
    pre_sign_up                    = var.lambda_pre_sign_up
    pre_token_generation           = var.lambda_pre_token_generation
    user_migration                 = var.lambda_user_migration
    verify_auth_challenge_response = var.lambda_verify_auth_challenge_response
    kms_key_id                     = var.lambda_kms_key_id

    dynamic "custom_email_sender" {
      for_each = var.lambda_custom_email_sender != null ? [var.lambda_custom_email_sender] : []
      content {
        lambda_arn     = lookup(var.lambda_custom_email_sender, "lambda_arn", null)
        lambda_version = lookup(var.lambda_custom_email_sender, "lambda_version", null)
      }
    }

    dynamic "custom_sms_sender" {
      for_each = var.lambda_custom_sms_sender != null ? [var.lambda_custom_sms_sender] : []
      content {
        lambda_arn     = lambda_custom_sms_sender.lambda_arn
        lambda_version = lambda_custom_sms_sender.lambda_version
      }
    }
  }

  dynamic "password_policy" {
    for_each = var.password_policy != null ? [var.password_policy] : []
    content {
      minimum_length                   = password_policy.value.minimum_length
      require_lowercase                = password_policy.value.require_lowercase
      require_numbers                  = password_policy.value.require_numbers
      require_symbols                  = password_policy.value.require_symbols
      require_uppercase                = password_policy.value.require_uppercase
      temporary_password_validity_days = password_policy.value.temporary_password_validity_days
    }
  }

  dynamic "schema" {
    for_each = var.schemata != null ? var.schemata : []
    iterator = schema
    content {
      name                     = schema.value.name
      required                 = try(schema.value.required, false)
      attribute_data_type      = schema.value.data_type
      developer_only_attribute = try(schema.value.developer_only_attribute, false)
      mutable                  = try(schema.value.mutable, true)

      dynamic "number_attribute_constraints" {
        for_each = schema.value.data_type == "Number" ? [true] : []

        content {
          min_value = lookup(schema.value, "min_value", null)
          max_value = lookup(schema.value, "max_value", null)
        }
      }

      dynamic "string_attribute_constraints" {
        for_each = schema.value.data_type == "String" ? [true] : []

        content {
          min_length = lookup(schema.value, "min_length", 0)
          max_length = lookup(schema.value, "max_length", 2048)
        }
      }

    }
  }

  dynamic "sms_configuration" {
    for_each = var.sms_configuration != null ? [var.sms_configuration] : []
    content {
      external_id    = var.sms_configuration.external_id
      sns_caller_arn = var.sms_configuration.sns_caller_arn
    }
  }

  dynamic "software_token_mfa_configuration" {
    for_each = var.allow_software_mfa_token ? [true] : []
    content {
      enabled = true
    }
  }

  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  username_configuration {
    case_sensitive = var.case_sensitive_usernames
  }

  dynamic "verification_message_template" {
    for_each = var.verification_message_template != null ? [var.verification_message_template] : []
    content {
      default_email_option  = verification_message_template.value.default_email_option
      email_message         = verification_message_template.value.email_message
      email_message_by_link = verification_message_template.value.email_message_by_link
      email_subject         = verification_message_template.value.email_subject
      email_subject_by_link = verification_message_template.value.email_subject_by_link
      sms_message           = verification_message_template.value.sms_message
    }
  }

  lifecycle {
    replace_triggered_by = [null_resource.schema_checksum]
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_domain" "this" {
  count           = var.domain != null ? 1 : 0
  domain          = var.domain
  user_pool_id    = aws_cognito_user_pool.this.id
  certificate_arn = var.domain_certificate_arn
}

resource "aws_cognito_user_pool_client" "this" {
  count        = var.client_name != null ? 1 : 0
  name         = var.client_name
  user_pool_id = aws_cognito_user_pool.this.id

  allowed_oauth_flows                  = var.client_oauth_grant_types
  allowed_oauth_flows_user_pool_client = var.client_oauth_flow_allowed
  allowed_oauth_scopes                 = var.resource_server_name != null ? aws_cognito_resource_server.this[0].scope_identifiers : var.client_oauth_scopes

  enable_token_revocation                       = var.client_enable_token_revocation
  enable_propagate_additional_user_context_data = var.client_propagate_user_data
  explicit_auth_flows                           = var.client_auth_flows
  generate_secret                               = var.client_generate_secret

  supported_identity_providers = var.client_identity_providers

  callback_urls        = var.client_callback_urls
  default_redirect_uri = var.client_redirect_uri
  logout_urls          = var.client_logout_urls

  read_attributes  = var.client_read_attributes
  write_attributes = var.client_write_attributes

  prevent_user_existence_errors = var.client_prevent_user_existence_errors ? "ENABLED" : "LEGACY"

  access_token_validity  = var.client_access_token_validity
  id_token_validity      = var.client_id_token_validity
  refresh_token_validity = var.client_refresh_token_validity

  # "seconds", "minutes", "hours", or "days"
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

resource "aws_cognito_resource_server" "this" {
  count        = var.resource_server_name != null ? 1 : 0
  name         = var.resource_server_name
  identifier   = var.resource_server_identifier
  user_pool_id = aws_cognito_user_pool.this.id

  dynamic "scope" {
    for_each = toset(var.resource_server_scopes)
    content {
      scope_name        = scope.value.scope_name
      scope_description = scope.value.scope_description
    }
  }
}
