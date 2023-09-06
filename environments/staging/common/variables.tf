variable "environment" {
  description = "Build environment"
  type        = string
  default     = "staging"
}

variable "domain_name" {
  description = "Domain name of the service."
  type        = string
  default     = "ott-staging.co.uk"
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

variable "newrelic_license_key" {
  description = "License key for NewRelic."
  type        = string
  sensitive   = true
}

variable "backend_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the backend."
  type        = string
  sensitive   = true
}

variable "frontend_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the frontend."
  type        = string
  sensitive   = true
}

variable "duty_calculator_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the duty calculator."
  type        = string
  sensitive   = true
}

variable "admin_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the admin tool."
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

variable "tariff_backend_sync_host" {
  description = "Value of Tariff Sync host. Used to fetch CDS files"
  type        = string
  sensitive   = true
}

variable "tariff_backend_sync_password" {
  description = "Value of Tariff Sync password."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sync_username" {
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
