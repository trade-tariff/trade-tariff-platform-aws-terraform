variable "environment" {
  description = "Build environment"
  type        = string
  default     = "development"
}

variable "domain_name" {
  description = "Domain name of the service."
  type        = string
  default     = "dev.trade-tariff.service.gov.uk"
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

variable "waf_rpm_limit" {
  description = "Request per minute limit for the WAF. This limit applies to our main CDN distribution and applies to all aliases on that CDN. "
  type        = number
  default     = 400
}

variable "circleci_organisation_id" {
  type        = string
  description = "The CircleCI organization ID for OIDC integration"
  sensitive   = true
}

variable "thumbprint_list" {
  type        = list(string)
  description = "List of thumbprints for the OIDC provider."
  default     = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280", "06B25927C42A721631C1EFD9431E648FA62E1E39"]
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

variable "dev_hub_backend_encryption_key" {
  description = "Value of ENCRYPTION_KEY for the dev hub backend."
  type        = string
  sensitive   = true
}

variable "dev_hub_backend_sentry_dsn" {
  description = "Value of SENTRY_DSN for the dev hub backend."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_sentry_dsn" {
  description = "Value of SENTRY_DSN for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_scp_open_id_client_id" {
  description = "Value of SCP_OPEN_ID_CLIENT_ID for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_scp_open_id_client_secret" {
  description = "Value of SCP_OPEN_ID_CLIENT_SECRET for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_scp_open_id_secret" {
  description = "Value of SCP_OPEN_ID_SECRET for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "fpo_search_sentry_dsn" {
  description = "Value of SENTRY_DSN for the FPO search lambda."
  type        = string
  sensitive   = true
}

variable "fpo_search_training_pem" {
  description = "Private ed25519 ssh pem used to generate training model artifacts in EC2. This is development, only."
  type        = string
  sensitive   = true
}

variable "backups_basic_auth" {
  description = "base64 encoded credentials for backups basic auth."
  type        = string
  sensitive   = true
}

variable "slack_notify_lambda_slack_webhook_url" {
  description = "Value of SLACK_WEB_HOOK_URL for the slack notify lambda."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_govuk_notify_api_key" {
  description = "Value of GOVUK_NOTIFY_API_KEY for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_application_support_email" {
  description = "Value of APPLICATION_SUPPORT_EMAIL for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_cookie_signing_secret" {
  description = "Value of COOKIE_SIGNING_SECRET for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "dev_hub_frontend_csrf_signing_secret" {
  description = "Value of CSRF_SIGNING_SECRET for the dev hub frontend."
  type        = string
  sensitive   = true
}

variable "commodi_tea_cookie_signing_secret" {
  description = "Value of COOKIE_SIGNING_SECRET for the Commodi tea."
  type        = string
  sensitive   = true
}

variable "commodi_tea_fpo_search_api_key" {
  description = "Value of FPO_SEARCH_API_KEY for the Commodi tea."
  type        = string
  sensitive   = true
}
