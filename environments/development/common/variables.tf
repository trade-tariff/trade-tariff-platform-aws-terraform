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

variable "waf_apigw_rpm_limit" {
  description = "Request per minute limit for the WAF in front of the API Gateway. Split from waf_rpm_limit so the API Gateway limit can diverge from the CDN limit."
  type        = number
  default     = 2000
}

variable "waf_no_api_key_rpm_limit" {
  description = "Request per minute limit for requests that do not carry a UUID-shaped X-Api-Key header. Clients that do keep the higher waf_rpm_limit. Deliberately tiny in development so the two-tier split can be exercised end to end: unkeyed traffic should start returning 429 almost immediately, while requests carrying a UUID-shaped X-Api-Key keep flowing up to waf_rpm_limit."
  type        = number
  default     = 10
}

variable "waf_mcp_secret_token" {
  description = "Secret token sent by the MCP server in X-Mcp-Token. On the API Gateway WAF only, requests carrying exactly this value are exempt from the per-IP rate limit (they are still inspected by the managed rule groups, and are rate-limited by the shared MCP usage plan instead). Also redacted from WAF logs. Empty keeps the plain per-IP limit for all traffic."
  type        = string
  sensitive   = true
  default     = ""
}

variable "mcp_usage_plan_key" {
  description = "Value of the API Gateway key tied to the shared MCP usage plan. Returned by the authorizer as usageIdentifierKey for requests carrying a valid X-Mcp-Token, so MCP traffic is throttled globally rather than per end user. Empty disables the plan."
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.mcp_usage_plan_key == "" || (length(var.mcp_usage_plan_key) >= 20 && length(var.mcp_usage_plan_key) <= 128)
    error_message = "mcp_usage_plan_key must be empty (disables the shared MCP usage plan) or 20-128 characters, matching API Gateway's api key value length requirement."
  }
}

variable "WAF_E2E_SECRET_TOKEN" {
  description = "Secret token sent by the e2e test suite in X-WAF-Bypass. Requests presenting this header bypass bot control and are allowed unconditionally."
  type        = string
  sensitive   = true
  default     = ""
}

variable "tss_scraper_ip" {
  description = "TSS Tariff Scraper source IP (CIDR), exempted from the general WAF rate limit and pinned to its own 500 RPM cap. Remove after 2027-01-01, HMRC-2501."
  type        = string
  default     = "20.49.214.59/32"
}

variable "enable_sns_alerts" {
  description = "Enable SNS alerts for all CloudWatch alarms"
  type        = bool
  default     = false
}
