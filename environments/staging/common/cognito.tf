module "dev_hub_cognito" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cognito?ref=aws/cognito-v1.1.1"

  pool_name              = "fpo-user-pool"
  domain                 = "auth.${var.domain_name}"
  domain_certificate_arn = module.acm.validated_certificate_arn

  client_name               = "hub-frontend-client"
  client_generate_secret    = true
  client_oauth_grant_types  = ["client_credentials"]
  client_oauth_flow_allowed = true

  resource_server_name       = "hub-backend-${var.environment}"
  resource_server_identifier = "hub-backend-server"

  resource_server_scopes = [
    {
      scope_name        = "api"
      scope_description = "Protected API route."
    }
  ]
}

resource "aws_route53_record" "cognito_custom_domain" {
  name    = "auth.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  alias {
    evaluate_target_health = false
    name                   = module.dev_hub_cognito.cloudfront_distribution_arn
    zone_id                = module.dev_hub_cognito.cloudfront_distribution_zone_id
  }
}

resource "aws_ssm_parameter" "cognito_public_keys" {
  name        = "/${var.environment}/FPO_DEVELOPER_HUB_COGNITO_PUBLIC_USER_URL"
  description = "Cognito public keys URL."
  type        = "SecureString"
  value       = module.dev_hub_cognito.user_pool_public_keys_url
}

module "cognito_client_id" {
  source          = "../../../modules/common/secret/"
  name            = "cognito-fpo-client-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.dev_hub_cognito.client_id
}

module "cognito_client_secret" {
  source          = "../../../modules/common/secret/"
  name            = "cognito-fpo-client-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.dev_hub_cognito.client_secret
}

module "commodi_tea_cognito" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cognito?ref=aws/cognito-v1.1.1"

  pool_name              = "commodi-tea-user-pool"
  domain                 = "auth.tea.${var.domain_name}"
  domain_certificate_arn = module.acm.validated_certificate_arn

  client_name            = "tea-client"
  client_generate_secret = true

  client_oauth_flow_allowed = true
  allow_user_registration   = true
  alias_attributes          = ["email", "preferred_username"]
  client_oauth_grant_types  = ["code", "implicit"]
  client_oauth_scopes       = ["openid", "email", "profile"]
  client_callback_urls      = ["https://tea.${var.domain_name}"]
  client_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}

resource "aws_route53_record" "tea_cognito_custom_domain" {
  name    = "auth.tea.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  alias {
    evaluate_target_health = false
    name                   = module.commodi_tea_cognito.cloudfront_distribution_arn
    zone_id                = module.commodi_tea_cognito.cloudfront_distribution_zone_id
  }
}

resource "aws_ssm_parameter" "tea_cognito_public_keys" {
  name        = "/${var.environment}/COMMODI_TEA_COGNITO_PUBLIC_USER_URL"
  description = "Commodi-Tea Cognito public keys URL."
  type        = "SecureString"
  value       = module.commodi_tea_cognito.user_pool_public_keys_url
}

module "tea_cognito_client_id" {
  source          = "../../../modules/common/secret/"
  name            = "tea-cognito-client-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.commodi_tea_cognito.client_id
}

module "tea_cognito_client_secret" {
  source          = "../../../modules/common/secret/"
  name            = "tea-cognito-client-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.commodi_tea_cognito.client_secret
}
