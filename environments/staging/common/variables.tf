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

variable "waf_rpm_limit" {
  description = "Request per minute limit for the WAF. This limit applies to our main CDN distribution and applies to all aliases on that CDN. "
  type        = number
  default     = 2000
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

variable "tss_scraper_ip" {
  description = "TSS Tariff Scraper source IP (CIDR), exempted from the general WAF rate limit and pinned to its own 500 RPM cap. Remove after 2027-01-01, HMRC-2501."
  type        = string
  default     = "20.49.214.59/32"
}

variable "enable_slack_alerts" {
  description = "Enable Slack notifications for request-path CloudWatch alarms (5xx, latency, Lambda errors)"
  type        = bool
  default     = false
}

variable "enable_critical_alerts" {
  description = "Enable critical-email notifications for alarms that protect the alerting pipeline and data-tier resources (slack_notify self-monitor, Valkey memory)"
  type        = bool
  default     = true
}
