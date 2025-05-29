variable "pool_name" {
  description = "Name of the user pool."
  type        = string
}

variable "alias_attributes" {
  description = "Attributes supported as an alias for the user pool."
  type        = list(string)
  default     = null
}

variable "auto_verified_attributes" {
  description = "Attributes to be automatically verified."
  type        = list(string)
  default     = []
}

variable "mfa_configuration" {
  description = "Multi-factor authentication setting. On, off, or optional (default)."
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = var.mfa_configuration == "ON" || var.mfa_configuration == "OFF" || var.mfa_configuration == "OPTIONAL"
    error_message = "Must be one of 'OFF', 'ON', or 'OPTIONAL'."
  }
}

variable "sms_authentication_message" {
  description = "String to use as the SMS authentication message. Must contain '{####}' placeholder."
  type        = string
  default     = "Your temporary password is {####}."

  validation {
    condition     = length(regexall("{####}", var.sms_authentication_message)) > 0
    error_message = "The SMS authentication message must contain the placeholder '{####}'."
  }
}

variable "username_attributes" {
  description = "If email addresses, and/or phone numbers can be used as usernames when a user signs up."
  type        = list(string)
  default     = null
}

variable "recovery_mechanisms" {
  description = "List of account recovery options objects."
  type = list(object({
    name     = string
    priority = number
  }))
  default = [{
    name     = "verified_email"
    priority = 1
  }]
}

variable "allow_user_registration" {
  description = "Whether users can sign themselves up. If false, only the administrator can create user profiles."
  type        = bool
  default     = false
}

variable "invite_message_template" {
  description = "Invite message template"
  type = object({
    email_subject = string
    email_message = string
    sms_message   = string
  })
  default = {
    email_subject = "Your New Account"
    email_message = "Your username is {username} and your temporary password is '{####}'."
    sms_message   = "Your username is {username} and your temporary password is '{####}'."
  }
}

# device_configuration
variable "device_configuration" {
  description = "Device configuration options. Whether to challenge on a new device, and whether a device is remembered (where false is 'always', and true is 'user opt in'). Omit block (default) for 'no'."
  type = object({
    challenge_required_on_new_device      = bool
    device_only_remembered_on_user_prompt = string
  })
  default = null
}

variable "email_configuration_set" {
  description = "Email configuration set name from SES."
  type        = string
  default     = null
}

variable "from_email_address" {
  description = "Sender's email address, or display name with their email address."
  type        = string
  default     = null
}

variable "reply_to_email_address" {
  description = "Reply-to email address."
  type        = string
  default     = null
}

variable "ses_identity_source_arn" {
  description = "ARN of the SES verified email identity to use - required if using SES."
  type        = string
  default     = null
}

variable "lambda_create_auth_challenge_arn" {
  description = "The ARN of the Lambda creating an authentication challenge."
  type        = string
  default     = null
}

variable "lambda_custom_message" {
  description = "The ARN of a custom message Lambda trigger."
  type        = string
  default     = null
}

variable "lambda_define_auth_challenge" {
  description = "The ARN of a Lambda that defines the authentication challenge."
  type        = string
  default     = null
}

variable "lambda_post_authentication" {
  description = "The ARN of a post-authentication Lambda trigger."
  type        = string
  default     = null
}

variable "lambda_post_confirmation" {
  description = "The ARN of a post-confirmation Lambda trigger."
  type        = string
  default     = null
}

variable "lambda_pre_authentication" {
  description = "The ARN of a pre-authentication Lambda trigger."
  type        = string
  default     = null
}

variable "lambda_pre_sign_up" {
  description = "The ARN of a pre-registration Lambda trigger."
  type        = string
  default     = null
}

variable "lambda_pre_token_generation" {
  description = "The ARN of a Lambda that allows customisation of identity token claims, pre-generation."
  type        = string
  default     = null
}

variable "lambda_user_migration" {
  description = "The ARN of the user migration Lambda config type."
  type        = string
  default     = null
}

variable "lambda_verify_auth_challenge_response" {
  description = "The ARN of the Lambda that verifies an authentication challenge."
  type        = string
  default     = null
}

variable "lambda_kms_key_id" {
  description = "The ARN of the KMS key for the custom email/sms sender."
  type        = string
  default     = null
}

variable "lambda_custom_email_sender" {
  description = "The ARN and version (V1_0) of the Lambda function that Cognito uses to send emails."
  type = object({
    lambda_arn     = string
    lambda_version = string
  })
  default = null
}

variable "lambda_custom_sms_sender" {
  description = "The ARN and version (V1_0) of the Lambda function that Cognito uses to send SMS messages."
  type = object({
    lambda_arn     = string
    lambda_version = string
  })
  default = null
}

variable "password_policy" {
  description = "Object containing the password policy."
  type = object({
    minimum_length                   = number
    password_history_size            = number
    require_lowercase                = bool
    require_numbers                  = bool
    require_symbols                  = bool
    require_uppercase                = bool
    temporary_password_validity_days = number
  })
  default = {
    minimum_length                   = 12
    password_history_size            = 0
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 1
  }
}

variable "schemata" {
  description = "List of schema objects."
  type        = any
  default     = null
}

variable "sms_configuration" {
  description = "SMS configuration object. Contains external_id and sns_caller_arn."
  type = object({
    external_id    = string
    sns_caller_arn = string
  })
  default = null
}

variable "allow_software_mfa_token" {
  description = "Whether to enable software token MFA tokens, such as TOTP."
  type        = bool
  default     = true
}

variable "advanced_security_mode" {
  description = "Advanced security mode. Must be one of 'OFF', 'AUDIT', or 'ENFORCED'."
  type        = string
  default     = "OFF"
}

variable "case_sensitive_usernames" {
  description = "Whether usernames are case sensitive. Defaults to false."
  type        = bool
  default     = false
}

variable "verification_message_template" {
  description = "Verification message object."
  type = object({
    default_email_option  = string
    email_message         = string
    email_message_by_link = string
    email_subject         = string
    email_subject_by_link = string
    sms_message           = string
  })
  default = {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_message         = "Your verification code is {####}."
    email_message_by_link = "Please click the link to verify your email address. {##Verify email##}."
    email_subject         = "Your Verification Code"
    email_subject_by_link = "Your Verification Link"
    sms_message           = "Your verification code is {####}."
  }
}

variable "domain" {
  description = "Domain for the user pool. If providing a FQDN, a certificate arn should be provided."
  type        = string
  default     = null
}

variable "domain_certificate_arn" {
  description = "The ARN of an issued ACM certificate, from us-east-1, for the custom domain."
  type        = string
  default     = null
}

variable "client_name" {
  description = "Name of the pool client. Defaults to `null`, disabling creation of the client."
  type        = string
  default     = null
}

variable "client_enable_token_revocation" {
  description = "Whether tokens can be revoked. Defaults to `true`."
  type        = bool
  default     = true
}

variable "client_prevent_user_existence_errors" {
  description = "Whether the API returns a generic authentication error (default), or indicates whether the user was not found."
  type        = bool
  default     = true
}

# https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-authentication-flow.html?icmpid=docs_cognito_console_help_panel
variable "client_auth_flows" {
  description = "Authentication flows the client supports."
  type        = list(string)
  default     = null
}

variable "client_propagate_user_data" {
  description = "Whether to propagate additional user data to the advanced security features of the Cognito user pool. Requires advanced security features on the user pool."
  type        = bool
  default     = false
}

variable "client_oauth_grant_types" {
  description = "A list of OAuth grant types that configure how Cognito delivers tokens to the client."
  type        = list(string)
  default     = null
}

variable "client_oauth_scopes" {
  description = "OpenID Connect (OIDC) scopes that the client can retrieve for access tokens."
  type        = list(string)
  default     = null
}

variable "client_auth_session_validity" {
  description = "Time (in minutes) for session to be valid in authentication flow. Defaults to `3` (minimum). Maximum value is `15`."
  type        = number
  default     = 3
}

variable "client_read_attributes" {
  description = "A list of Cognito attributes the client can read from."
  type        = list(string)
  default     = null
}

variable "client_write_attributes" {
  description = "A list of Cognito attributes the client can write to."
  type        = list(string)
  default     = null
}

variable "client_callback_urls" {
  description = "A list of callback URLs for the client identity providers."
  type        = list(string)
  default     = null
}

variable "client_redirect_uri" {
  description = "The client's default redirect URI. Must also be found within the client callback URLs variable."
  type        = string
  default     = null
}

variable "client_logout_urls" {
  description = "A list of logout URLs for the client identity providers."
  type        = list(string)
  default     = null
}

variable "client_identity_providers" {
  description = "List of `provider_name`s from Cognito Identity Providers."
  type        = list(string)
  default     = null
}

variable "client_oauth_flow_allowed" {
  description = "Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools."
  type        = bool
  default     = false
}

variable "client_generate_secret" {
  description = "Whether to generate a client secret for this application client."
  type        = bool
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "resource_server_name" {
  type        = string
  description = "Name of the resource server. Leave blank to not create resource server (default)."
  default     = null
}

variable "resource_server_identifier" {
  type        = string
  description = "Identifier of the resource server."
  default     = null
}

variable "resource_server_scopes" {
  type = list(object({
    scope_name        = string
    scope_description = string
  }))
  description = "List of scopes for resource server."
  default     = null
}

variable "client_token_validity" {
  type = object({
    access_token = optional(
      object({
        length = optional(number, 1)
        units  = optional(string, "hours")
      }),
      {
        length = 1
        units  = "hours"
      }
    )
    id_token = optional(
      object({
        length = optional(number, 1)
        units  = optional(string, "hours")
      }),
      {
        length = 1
        units  = "hours"
      }
    )
    refresh_token = optional(
      object({
        length = optional(number, 1)
        units  = optional(string, "hours")
      }),
      {
        length = 1
        units  = "hours"
      }
    )
  })

  description = "Client token validity settings. Units can be 'seconds', 'minutes', 'hours', or 'days'. Default to 1 hour for all tokens."

  default = {
    access_token = {
      length = 1
      units  = "hours"
    }
    id_token = {
      length = 1
      units  = "hours"
    }
    refresh_token = {
      length = 1
      units  = "hours"
    }
  }

}

variable "prevent_deletion" {
  type        = bool
  description = "Whether to prevent deletion of the user pool. Defaults to `true`."
  default     = true
}

variable "user_pool_tier" {
  type        = string
  description = "Feature plan name of the user pool. One of `LITE`, `ESSENTIALS`, or `PLUS`. Defaults to `LITE`."
  default     = "LITE"

  validation {
    condition     = var.user_pool_tier == "LITE" || var.user_pool_tier == "ESSENTIALS" || var.user_pool_tier == "PLUS"
    error_message = "Must be one of 'LITE', 'ESSENTIALS', or 'PLUS'."
  }
}

variable "allowed_first_auth_factors" {
  type        = list(string)
  description = "A list of sign in methods supported as the first factor. Any of `PASSWORD`, `EMAIL_OTP`, `SMS_OTP`, and `WEB_AUTHN`."
  default     = null
}
