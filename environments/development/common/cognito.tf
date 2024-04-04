module "dev_hub_cognito" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cognito?ref=aws/cognito-v1.1.1"

  pool_name              = "fpo-user-pool"
  domain                 = "auth.${var.domain_name}"
  domain_certificate_arn = module.acm.validated_certificate_arn

  client_name               = "hub-frontend-client"
  client_generate_secret    = true
  client_oauth_grant_types  = ["client_credentials"]
  client_oauth_flow_allowed = true

  resource_server_name       = "hub-backend"
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
  name        = "/${var.environment}/COGNITO_PUBLIC_KEYS_URL"
  description = "Cognito public keys URL."
  type        = "SecureString"
  value       = module.dev_hub_cognito.user_pool_public_keys_url
}

module "cognito_client_secret" {
  source          = "../../common/secret/"
  name            = "cognito-fpo-client-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.dev_hub_cognito.client_secret
}
