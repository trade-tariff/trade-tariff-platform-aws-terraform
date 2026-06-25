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

variable "waf_mcp_secret_token" {
  description = "Secret token sent by the MCP server in X-Mcp-Token. Requests presenting this header are allowed through WAF rate limiting."
  type        = string
  sensitive   = true
  default     = ""
}

variable "WAF_E2E_SECRET_TOKEN" {
  description = "Secret token sent by the e2e test suite in X-WAF-Bypass. Requests presenting this header bypass bot control and are allowed unconditionally."
  type        = string
  sensitive   = true
  default     = ""
}

variable "waf_page_rpm_limit" {
  description = "Rate limit per IP per minute for individual tariff page paths (commodities, headings, chapters, subheadings). Lower than the global limit to restrict scrapers walking the hierarchy."
  type        = number
  default     = 100
}

variable "waf_search_rpm_limit" {
  description = "Rate limit per IP per minute for the /search endpoint. Tighter than the page limit as search hits OpenSearch and is a primary scraper entry point."
  type        = number
  default     = 60
}

variable "enable_sns_alerts" {
  description = "Enable SNS alerts for all CloudWatch alarms"
  type        = bool
  default     = true
}
