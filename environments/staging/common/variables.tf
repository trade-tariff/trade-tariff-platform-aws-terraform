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

variable "fpo_search_sentry_dsn" {
  description = "Value of SENTRY_DSN for the FPO search lambda."
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
