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

variable "waf_rpm_limit" {
  description = "Request per minute limit for the WAF. This limit applies to our main CDN distribution and applies to all aliases on that CDN. "
  type        = number
  default     = 2000
}
