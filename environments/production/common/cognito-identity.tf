module "identity_cognito" {
  source = "../../../modules/cognito"

  pool_name      = "trade-tariff-identity-user-pool"
  user_pool_tier = "ESSENTIALS"

  allow_user_registration  = true
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OFF"
  allow_software_mfa_token = false

  username_attributes = ["email"]

  password_policy = {
    minimum_length                   = 12
    password_history_size            = 0
    require_lowercase                = true
    require_numbers                  = true
    require_uppercase                = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  schemata = [
    {
      name      = "email"
      data_type = "String"
      required  = true
    }
  ]

  recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

  lambda_create_auth_challenge_arn      = module.create_auth_challenge.lambda_arn
  lambda_define_auth_challenge          = module.define_auth_challenge.lambda_arn
  lambda_verify_auth_challenge_response = module.verify_auth_challenge.lambda_arn

  # Client options

  client_name = "identity-client"
  client_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  client_oauth_flow_allowed = true
  client_oauth_grant_types  = ["code"]

  client_oauth_scopes = [
    "email",
    "openid",
    "phone"
  ]

  client_auth_session_validity   = 15
  client_enable_token_revocation = false

  client_token_validity = {
    access_token = {
      length = 1
      units  = "days"
    }
    id_token = {
      length = 1
      units  = "days"
    }
    refresh_token = {
      length = 5
      units  = "days"
    }
  }

  client_callback_urls = [
    "https://id.${var.domain_name}/auth"
  ]

  client_identity_providers = ["COGNITO"]

  user_groups = [
    {
      name        = "myott"
      description = "MyOTT user group"
    }
  ]
}
