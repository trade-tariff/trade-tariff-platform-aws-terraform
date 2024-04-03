module "cognito" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cognito?ref=aws/cognito-v1.1.1"

  pool_name              = "fpo-user-pool"
  domain                 = "auth.${var.domain_name}"
  domain_certificate_arn = module.acm.validated_certificate_arn

  client_name               = "fpo-client"
  client_generate_secret    = true
  client_oauth_grant_types  = ["client_credentials"]
  client_oauth_flow_allowed = true

  resource_server_name       = "fpo"
  resource_server_identifier = "fpo-server"

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
    name                   = module.cognito.cloudfront_distribution_arn
    zone_id                = module.cognito.cloudfront_distribution_zone_id
  }
}

resource "aws_ssm_parameter" "cognito_public_keys" {
  name        = "/COGNITO_PUBLIC_KEYS_URL"
  description = "Cognito public keys URL."
  type        = "SecureString"
  value       = module.cognito.user_pool_public_keys_url
}

module "cognito_client_secret" {
  source          = "../../common/secret/"
  name            = "cognito-fpo-client-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.cognito.client_secret
}
