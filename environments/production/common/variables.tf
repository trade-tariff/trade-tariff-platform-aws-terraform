variable "environment" {
  description = "Build environment"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Domain name of the service."
  type        = string
  default     = "trade-tariff.service.gov.uk"
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
  default     = 500
}

variable "newrelic_license_key" {
  description = "New Relic ingest license key"
  type        = string
  sensitive   = true
}
