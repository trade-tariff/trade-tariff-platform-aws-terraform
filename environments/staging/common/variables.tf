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
    Environment = "development"
    Billing     = "TRN.HMR11896"
  }
}

variable "waf_rpm_limit" {
  description = "Request per minute limit for the WAF."
  type        = number
  default     = 100
}
