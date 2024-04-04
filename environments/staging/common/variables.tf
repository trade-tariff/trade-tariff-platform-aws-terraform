variable "environment" {
  description = "Build environment"
  type        = string
  default     = "staging"
}

variable "domain_name" {
  description = "Domain name of the service."
  type        = string
  default     = "staging.trade-tariff.service.gov.uk"
}

variable "sandbox_domain_name" {
  description = "Sandbox domain name of the service."
  type        = string
  default     = "sandbox.trade-tariff.service.gov.uk"
}

variable "region" {
  description = "AWS Region to use. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "account_ids" {
  type = map(string)
  default = {
    "development" = "844815912454"
    "staging"     = "451934005581"
    "production"  = "382373577178"
  }
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default = {
    Terraform   = true
    Project     = "trade-tariff"
    Environment = "staging"
    Billing     = "TRN.HMR11896"
  }
}

variable "waf_rpm_limit" {
  description = "Request per minute limit for the WAF."
  type        = number
  default     = 500
}

#
# super secret stuff
#

variable "backend_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the backend."
  type        = string
  sensitive   = true
}

variable "slack_web_hook_url" {
  description = "Value of SLACK_WEB_HOOK_URL for the backend."
  type        = string
  sensitive   = true
}

variable "frontend_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the frontend."
  type        = string
  sensitive   = true
}

variable "frontend_sentry_dsn" {
  description = "Value of SENTRY_DSN for the frontend."
  type        = string
  sensitive   = true
}

variable "duty_calculator_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the duty calculator."
  type        = string
  sensitive   = true
}

variable "duty_calculator_sentry_dsn" {
  description = "Value of SENTRY_DSN for the duty calculator."
  type        = string
  sensitive   = true
}

variable "admin_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the admin tool."
  type        = string
  sensitive   = true
}

variable "admin_sentry_dsn" {
  description = "Value of Sentry DSN for the admin tool."
  type        = string
  sensitive   = true
}

variable "signon_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the signon app."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sentry_dsn" {
  description = "Value of Backend Sentry DSN."
  type        = string
  sensitive   = true
}

variable "admin_oauth_id" {
  description = "Value of TARIFF_ADMIN_OAUTH_ID for the admin tool."
  type        = string
  sensitive   = true
}

variable "tariff_backend_differences_to_emails" {
  description = "Differences report TO email addresses."
  type        = string
  sensitive   = true
}

variable "tariff_backend_green_lanes_api_tokens" {
  description = "Value of GREEN_LANES_API_TOKENS for the tariff backend."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sync_email" {
  description = "Value of Tariff Sync email."
  type        = string
  sensitive   = true
}

variable "admin_oauth_secret" {
  description = "Value of TARIFF_ADMIN_OAUTH_SECRET for the admin tool."
  type        = string
  sensitive   = true
}

variable "admin_bearer_token" {
  description = "Value of BEARER_TOKEN for the admin tool."
  type        = string
  sensitive   = true
}

variable "tariff_backend_uk_sync_host" {
  description = "Value of Tariff Sync host."
  type        = string
  sensitive   = true
}

variable "tariff_backend_uk_sync_password" {
  description = "Value of Tariff Sync password."
  type        = string
  sensitive   = true
}

variable "tariff_backend_uk_sync_username" {
  description = "Value of Tariff Sync username."
  type        = string
  sensitive   = true
}

variable "tariff_backend_xi_sync_host" {
  description = "Value of Tariff Sync host."
  type        = string
  sensitive   = true
}

variable "tariff_backend_xi_sync_password" {
  description = "Value of Tariff Sync password."
  type        = string
  sensitive   = true
}

variable "tariff_backend_xi_sync_username" {
  description = "Value of Tariff Sync username."
  type        = string
  sensitive   = true
}

variable "tariff_backend_oauth_id" {
  description = "Value of Tariff Backend OAuth ID."
  type        = string
  sensitive   = true
}

variable "tariff_backend_oauth_secret" {
  description = "Value of Tariff Backend OAuth secret."
  type        = string
  sensitive   = true
}

variable "tariff_backend_xe_api_username" {
  description = "Value of XE_API_USERNAME for the tariff backend."
  type        = string
  sensitive   = true
}

variable "tariff_backend_xe_api_password" {
  description = "Value of XE_API_PASSWORD for the tariff backend."
  type        = string
  sensitive   = true
}

variable "signon_devise_pepper" {
  description = "Value of DEVISE_PEPPER for the signon app."
  type        = string
  sensitive   = true
}

variable "signon_devise_secret_key" {
  description = "Value of DEVISE_SECRET_KEY for the signon app."
  type        = string
  sensitive   = true
}

variable "signon_govuk_notify_api_key" {
  description = "Value of GOVUK_NOTIFY_API_KEY for the signon app."
  type        = string
  sensitive   = true
}

variable "signon_derivation_salt" {
  description = "Value of ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT for the signon app."
  type        = string
  sensitive   = true
}

variable "signon_derivation_key" {
  description = "Value of ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY for the signon app."
  type        = string
  sensitive   = true
}

variable "search_query_parser_sentry_dsn" {
  description = "Value of SENTRY_DSN for the search query parser."
  type        = string
  sensitive   = true
}

variable "dev_hub_backend_encryption_key" {
  description = "Value of ENCRYPTION_KEY for the dev hub backend."
  type        = string
  sensitive   = true
}

variable "dev_hub_backend_usage_plan_id" {
  description = "Value of USAGE_PLAN_ID for the dev hub backend."
  type        = string
  sensitive   = true
}

variable "backups_basic_auth" {
  description = "base64 encoded credentials for backups basic auth."
  type        = string
  sensitive   = true
}
