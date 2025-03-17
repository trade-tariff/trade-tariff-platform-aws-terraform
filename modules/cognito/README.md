# terraform-aws-cognito

A Terraform module for AWS Cognito.

## Custom Domains

If you are using a custom domain with the Cognito user pool, you will need to
add an A record, as below:

```hcl
variable "base_domain" {
  type    = string
  default = "example.com"
}

data "aws_route53_zone" "this" {
  name         = "example.com"
  private_zone = false
}

resource "aws_route53_record" "cognito_custom_domain" {
  name    = "auth.example.com"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id
  alias {
    evaluate_target_health = false
    name                   = module.cognito_user_pool.cloudfront_distribution_arn
    zone_id                = "" # CloudFront Zone ID, fixed
  }
}
```

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.91.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cognito_resource_server.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [null_resource.schema_checksum](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_security_mode"></a> [advanced\_security\_mode](#input\_advanced\_security\_mode) | Advanced security mode. Must be one of 'OFF', 'AUDIT', or 'ENFORCED'. | `string` | `"OFF"` | no |
| <a name="input_alias_attributes"></a> [alias\_attributes](#input\_alias\_attributes) | Attributes supported as an alias for the user pool. | `list(string)` | `null` | no |
| <a name="input_allow_software_mfa_token"></a> [allow\_software\_mfa\_token](#input\_allow\_software\_mfa\_token) | Whether to enable software token MFA tokens, such as TOTP. | `bool` | `true` | no |
| <a name="input_allow_user_registration"></a> [allow\_user\_registration](#input\_allow\_user\_registration) | Whether users can sign themselves up. If false, only the administrator can create user profiles. | `bool` | `false` | no |
| <a name="input_auto_verified_attributes"></a> [auto\_verified\_attributes](#input\_auto\_verified\_attributes) | Attributes to be automatically verified. | `list(string)` | `[]` | no |
| <a name="input_case_sensitive_usernames"></a> [case\_sensitive\_usernames](#input\_case\_sensitive\_usernames) | Whether usernames are case sensitive. Defaults to false. | `bool` | `false` | no |
| <a name="input_client_access_token_validity"></a> [client\_access\_token\_validity](#input\_client\_access\_token\_validity) | Time (in hours) for access tokens to be valid. Defaults to `1`. | `number` | `1` | no |
| <a name="input_client_auth_flows"></a> [client\_auth\_flows](#input\_client\_auth\_flows) | Authentication flows the client supports. | `list(string)` | `null` | no |
| <a name="input_client_callback_urls"></a> [client\_callback\_urls](#input\_client\_callback\_urls) | A list of callback URLs for the client identity providers. | `list(string)` | `null` | no |
| <a name="input_client_enable_token_revocation"></a> [client\_enable\_token\_revocation](#input\_client\_enable\_token\_revocation) | Whether tokens can be revoked. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_client_generate_secret"></a> [client\_generate\_secret](#input\_client\_generate\_secret) | Whether to generate a client secret for this application client. | `bool` | `false` | no |
| <a name="input_client_id_token_validity"></a> [client\_id\_token\_validity](#input\_client\_id\_token\_validity) | Time (in hours) for ID tokens to be valid. Defaults to `1`. | `number` | `1` | no |
| <a name="input_client_identity_providers"></a> [client\_identity\_providers](#input\_client\_identity\_providers) | List of `provider_name`s from Cognito Identity Providers. | `list(string)` | `null` | no |
| <a name="input_client_logout_urls"></a> [client\_logout\_urls](#input\_client\_logout\_urls) | A list of logout URLs for the client identity providers. | `list(string)` | `null` | no |
| <a name="input_client_name"></a> [client\_name](#input\_client\_name) | Name of the pool client. Defaults to `null`, disabling creation of the client. | `string` | `null` | no |
| <a name="input_client_oauth_flow_allowed"></a> [client\_oauth\_flow\_allowed](#input\_client\_oauth\_flow\_allowed) | Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools. | `bool` | `false` | no |
| <a name="input_client_oauth_grant_types"></a> [client\_oauth\_grant\_types](#input\_client\_oauth\_grant\_types) | A list of OAuth grant types that configure how Cognito delivers tokens to the client. | `list(string)` | `null` | no |
| <a name="input_client_oauth_scopes"></a> [client\_oauth\_scopes](#input\_client\_oauth\_scopes) | OpenID Connect (OIDC) scopes that the client can retrieve for access tokens. | `list(string)` | `null` | no |
| <a name="input_client_prevent_user_existence_errors"></a> [client\_prevent\_user\_existence\_errors](#input\_client\_prevent\_user\_existence\_errors) | Whether the API returns a generic authentication error (default), or indicates whether the user was not found. | `bool` | `true` | no |
| <a name="input_client_propagate_user_data"></a> [client\_propagate\_user\_data](#input\_client\_propagate\_user\_data) | Whether to propagate additional user data to the advanced security features of the Cognito user pool. Requires advanced security features on the user pool. | `bool` | `false` | no |
| <a name="input_client_read_attributes"></a> [client\_read\_attributes](#input\_client\_read\_attributes) | A list of Cognito attributes the client can read from. | `list(string)` | `null` | no |
| <a name="input_client_redirect_uri"></a> [client\_redirect\_uri](#input\_client\_redirect\_uri) | The client's default redirect URI. Must also be found within the client callback URLs variable. | `string` | `null` | no |
| <a name="input_client_refresh_token_validity"></a> [client\_refresh\_token\_validity](#input\_client\_refresh\_token\_validity) | Time (in days) for refresh tokens to be valid. Defaults to `1`. | `number` | `1` | no |
| <a name="input_client_write_attributes"></a> [client\_write\_attributes](#input\_client\_write\_attributes) | A list of Cognito attributes the client can write to. | `list(string)` | `null` | no |
| <a name="input_device_configuration"></a> [device\_configuration](#input\_device\_configuration) | Device configuration options. Whether to challenge on a new device, and whether a device is remembered (where false is 'always', and true is 'user opt in'). Omit block (default) for 'no'. | <pre>object({<br/>    challenge_required_on_new_device      = bool<br/>    device_only_remembered_on_user_prompt = string<br/>  })</pre> | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for the user pool. If providing a FQDN, a certificate arn should be provided. | `string` | `null` | no |
| <a name="input_domain_certificate_arn"></a> [domain\_certificate\_arn](#input\_domain\_certificate\_arn) | The ARN of an issued ACM certificate, from us-east-1, for the custom domain. | `string` | `null` | no |
| <a name="input_email_configuration_set"></a> [email\_configuration\_set](#input\_email\_configuration\_set) | Email configuration set name from SES. | `string` | `null` | no |
| <a name="input_from_email_address"></a> [from\_email\_address](#input\_from\_email\_address) | Sender's email address, or display name with their email address. | `string` | `null` | no |
| <a name="input_invite_message_template"></a> [invite\_message\_template](#input\_invite\_message\_template) | Invite message template | <pre>object({<br/>    email_subject = string<br/>    email_message = string<br/>    sms_message   = string<br/>  })</pre> | <pre>{<br/>  "email_message": "Your username is {username} and your temporary password is '{####}'.",<br/>  "email_subject": "Your New Account",<br/>  "sms_message": "Your username is {username} and your temporary password is '{####}'."<br/>}</pre> | no |
| <a name="input_lambda_create_auth_challenge_arn"></a> [lambda\_create\_auth\_challenge\_arn](#input\_lambda\_create\_auth\_challenge\_arn) | The ARN of the Lambda creating an authentication challenge. | `string` | `null` | no |
| <a name="input_lambda_custom_email_sender"></a> [lambda\_custom\_email\_sender](#input\_lambda\_custom\_email\_sender) | The ARN and version (V1\_0) of the Lambda function that Cognito uses to send emails. | <pre>object({<br/>    lambda_arn     = string<br/>    lambda_version = string<br/>  })</pre> | `null` | no |
| <a name="input_lambda_custom_message"></a> [lambda\_custom\_message](#input\_lambda\_custom\_message) | The ARN of a custom message Lambda trigger. | `string` | `null` | no |
| <a name="input_lambda_custom_sms_sender"></a> [lambda\_custom\_sms\_sender](#input\_lambda\_custom\_sms\_sender) | The ARN and version (V1\_0) of the Lambda function that Cognito uses to send SMS messages. | <pre>object({<br/>    lambda_arn     = string<br/>    lambda_version = string<br/>  })</pre> | `null` | no |
| <a name="input_lambda_define_auth_challenge"></a> [lambda\_define\_auth\_challenge](#input\_lambda\_define\_auth\_challenge) | The ARN of a Lambda that defines the authentication challenge. | `string` | `null` | no |
| <a name="input_lambda_kms_key_id"></a> [lambda\_kms\_key\_id](#input\_lambda\_kms\_key\_id) | The ARN of the KMS key for the custom email/sms sender. | `string` | `null` | no |
| <a name="input_lambda_post_authentication"></a> [lambda\_post\_authentication](#input\_lambda\_post\_authentication) | The ARN of a post-authentication Lambda trigger. | `string` | `null` | no |
| <a name="input_lambda_post_confirmation"></a> [lambda\_post\_confirmation](#input\_lambda\_post\_confirmation) | The ARN of a post-confirmation Lambda trigger. | `string` | `null` | no |
| <a name="input_lambda_pre_authentication"></a> [lambda\_pre\_authentication](#input\_lambda\_pre\_authentication) | The ARN of a pre-authentication Lambda trigger. | `string` | `null` | no |
| <a name="input_lambda_pre_sign_up"></a> [lambda\_pre\_sign\_up](#input\_lambda\_pre\_sign\_up) | The ARN of a pre-registration Lambda trigger. | `string` | `null` | no |
| <a name="input_lambda_pre_token_generation"></a> [lambda\_pre\_token\_generation](#input\_lambda\_pre\_token\_generation) | The ARN of a Lambda that allows customisation of identity token claims, pre-generation. | `string` | `null` | no |
| <a name="input_lambda_user_migration"></a> [lambda\_user\_migration](#input\_lambda\_user\_migration) | The ARN of the user migration Lambda config type. | `string` | `null` | no |
| <a name="input_lambda_verify_auth_challenge_response"></a> [lambda\_verify\_auth\_challenge\_response](#input\_lambda\_verify\_auth\_challenge\_response) | The ARN of the Lambda that verifies an authentication challenge. | `string` | `null` | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | Multi-factor authentication setting. On, off, or optional (default). | `string` | `"OPTIONAL"` | no |
| <a name="input_password_policy"></a> [password\_policy](#input\_password\_policy) | Object containing the password policy. | <pre>object({<br/>    minimum_length                   = number,<br/>    require_lowercase                = bool,<br/>    require_numbers                  = bool,<br/>    require_symbols                  = bool,<br/>    require_uppercase                = bool,<br/>    temporary_password_validity_days = number<br/>  })</pre> | <pre>{<br/>  "minimum_length": 12,<br/>  "require_lowercase": true,<br/>  "require_numbers": true,<br/>  "require_symbols": true,<br/>  "require_uppercase": true,<br/>  "temporary_password_validity_days": 1<br/>}</pre> | no |
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | Name of the user pool. | `string` | n/a | yes |
| <a name="input_recovery_mechanisms"></a> [recovery\_mechanisms](#input\_recovery\_mechanisms) | List of account recovery options objects. | <pre>list(object({<br/>    name     = string<br/>    priority = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "verified_email",<br/>    "priority": 1<br/>  }<br/>]</pre> | no |
| <a name="input_reply_to_email_address"></a> [reply\_to\_email\_address](#input\_reply\_to\_email\_address) | Reply-to email address. | `string` | `null` | no |
| <a name="input_resource_server_identifier"></a> [resource\_server\_identifier](#input\_resource\_server\_identifier) | Identifier of the resource server. | `string` | `null` | no |
| <a name="input_resource_server_name"></a> [resource\_server\_name](#input\_resource\_server\_name) | Name of the resource server. Leave blank to not create resource server (default). | `string` | `null` | no |
| <a name="input_resource_server_scopes"></a> [resource\_server\_scopes](#input\_resource\_server\_scopes) | List of scopes for resource server. | <pre>list(object({<br/>    scope_name        = string<br/>    scope_description = string<br/>  }))</pre> | `null` | no |
| <a name="input_schemata"></a> [schemata](#input\_schemata) | List of schema objects. | `any` | `null` | no |
| <a name="input_ses_identity_source_arn"></a> [ses\_identity\_source\_arn](#input\_ses\_identity\_source\_arn) | ARN of the SES verified email identity to use - required if using SES. | `string` | `null` | no |
| <a name="input_sms_authentication_message"></a> [sms\_authentication\_message](#input\_sms\_authentication\_message) | String to use as the SMS authentication message. Must contain '{####}' placeholder. | `string` | `"Your temporary password is {####}."` | no |
| <a name="input_sms_configuration"></a> [sms\_configuration](#input\_sms\_configuration) | SMS configuration object. Contains external\_id and sns\_caller\_arn. | <pre>object({<br/>    external_id    = string<br/>    sns_caller_arn = string<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_username_attributes"></a> [username\_attributes](#input\_username\_attributes) | If email addresses, and/or phone numbers can be used as usernames when a user signs up. | `list(string)` | `null` | no |
| <a name="input_verification_message_template"></a> [verification\_message\_template](#input\_verification\_message\_template) | Verification message object. | <pre>object({<br/>    default_email_option  = string<br/>    email_message         = string<br/>    email_message_by_link = string<br/>    email_subject         = string<br/>    email_subject_by_link = string<br/>    sms_message           = string<br/>  })</pre> | <pre>{<br/>  "default_email_option": "CONFIRM_WITH_CODE",<br/>  "email_message": "Your verification code is {####}.",<br/>  "email_message_by_link": "Please click the link to verify your email address. {##Verify email##}.",<br/>  "email_subject": "Your Verification Code",<br/>  "email_subject_by_link": "Your Verification Link",<br/>  "sms_message": "Your verification code is {####}."<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | n/a |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | n/a |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | n/a |
| <a name="output_cloudfront_distribution_zone_id"></a> [cloudfront\_distribution\_zone\_id](#output\_cloudfront\_distribution\_zone\_id) | n/a |
| <a name="output_domain"></a> [domain](#output\_domain) | n/a |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | n/a |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | n/a |
| <a name="output_user_pool_public_keys_url"></a> [user\_pool\_public\_keys\_url](#output\_user\_pool\_public\_keys\_url) | n/a |
<!-- END_TF_DOCS -->
