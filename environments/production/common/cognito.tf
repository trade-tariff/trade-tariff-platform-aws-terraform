module "dev_hub_cognito" {
  source = "../../../modules/cognito"

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
  source          = "../../../modules/secret/"
  name            = "cognito-fpo-client-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.dev_hub_cognito.client_id
}

module "cognito_client_secret" {
  source          = "../../../modules/secret/"
  name            = "cognito-fpo-client-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.dev_hub_cognito.client_secret
}

module "commodi_tea_cognito" {
  source = "../../../modules/cognito"

  pool_name              = "commodi-tea-user-pool"
  user_pool_tier         = "ESSENTIALS"
  domain                 = "auth.tea.${var.domain_name}"
  domain_certificate_arn = module.acm.validated_certificate_arn

  allow_user_registration  = false
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  schemata = [
    {
      name      = "email"
      required  = true
      data_type = "String"
    },
    {
      name      = "name"
      required  = true
      data_type = "String"
    },
    {
      name      = "family_name"
      required  = true
      data_type = "String"
    },
  ]

  client_name            = "tea-client"
  client_generate_secret = true

  client_oauth_flow_allowed = true
  client_oauth_grant_types = [
    "code",
    "implicit"
  ]

  client_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]

  client_callback_urls = [
    "https://tea.${var.domain_name}",
    "https://tea.${var.domain_name}/auth/redirect",
  ]

  client_identity_providers = ["COGNITO"]

  client_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  client_token_validity = {
    refresh_token = {
      units = "days"
    }
  }

  invite_message_template = {
    email_subject = "Your New 'Commodi-Tea' Account"
    email_message = <<EOT
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Account Invitation</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; background-color: #f9f9f9;">
    <table style="width: 100%; max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; padding: 20px;">
        <tr>
            <td>
                <p style="color: #555555;">You have been invited to access <a href="https://tea.trade-tariff.service.gov.uk/" style="color: #1a73e8;">Commodi-Tea</a>. Please use the following details to log in and set up your account:</p>

                <p style="color: #555555; margin-bottom: 4px;"><strong>Username:</strong> {username}</p>
                <p style="color: #555555; margin-top: 4px; margin-bottom: 4px;"><strong>Temporary Password:</strong> {####}</p>

                <p style="color: #555555; margin-top: 8px;">This invitation expires in 7 days.</p>

                <p style="color: #555555; margin-top: 4px;">You will be asked to provide your name and set up a new password as part of the setup process. For security reasons, please do not share these details with anyone.</p>

                <p style="color: #555555; margin-top: 16px;">If you require assistance, you may contact us at <a href="mailto:hmrc-trade-tariff-support-g@digital.hmrc.gov.uk" style="color: #1a73e8;">hmrc-trade-tariff-support-g@digital.hmrc.gov.uk</a>.</p>

                <p style="color: #555555; margin-bottom: 4px;">Best regards,</p>
                <p style="color: #555555; margin-top: 4px;">OTT Digital Support</p>
            </td>
        </tr>
    </table>
</body>
</html>
EOT
    sms_message   = "Your account has been created. Username: {username}, Temporary Password: {####}"
  }
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
  source          = "../../../modules/secret/"
  name            = "tea-cognito-client-id"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.commodi_tea_cognito.client_id
}

module "tea_cognito_client_secret" {
  source          = "../../../modules/secret/"
  name            = "tea-cognito-client-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = module.commodi_tea_cognito.client_secret
}

module "tea_cognito_secret" {
  source          = "../../../modules/secret/"
  name            = "tea-cognito-secret"
  kms_key_arn     = aws_kms_key.secretsmanager_kms_key.arn
  recovery_window = 7
  secret_string   = random_password.tea_cognito_secret.result
}

resource "random_password" "tea_cognito_secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
