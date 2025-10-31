module "identity_cognito" {
  source = "../../../modules/cognito"

  pool_name              = "trade-tariff-identity-user-pool"
  user_pool_tier         = "ESSENTIALS"
  domain                 = "auth.id.${var.domain_name}"
  domain_certificate_arn = module.acm.validated_certificate_arn

  allow_user_registration  = true
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OFF"
  allow_software_mfa_token = false

  username_attributes = ["email"]

  schemata = [
    {
      name      = "email"
      data_type = "String"
      required  = true
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
      length = 1
      units  = "days"
    }
  }

  user_groups = [
    {
      name        = "myott"
      description = "MyOTT user group"
    },
    {
      name        = "admin"
      description = "Admin user group. See https://admin.trade-tariff.service.gov.uk"
    },
    {
      name        = "portal"
      description = "Developer Portal user group. See https://portal.trade-tariff.service.gov.uk"
    }
  ]
}

resource "aws_route53_record" "id_cognito_custom_domain" {
  name    = "auth.id.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  alias {
    evaluate_target_health = false
    name                   = module.identity_cognito.cloudfront_distribution_arn
    zone_id                = module.identity_cognito.cloudfront_distribution_zone_id
  }
}
