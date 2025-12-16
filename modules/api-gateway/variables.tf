variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the application."
  type        = string
}

variable "validated_certificate_arn" {
  description = "The ARN of the validated SSL certificate."
  type        = string
}

variable "zone_id" {
  description = "The Route 53 Hosted Zone ID for the domain."
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to give access to the V2 VPC Link."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the V2 VPC Link."
  type        = list(string)
}

variable "lb_arn" {
  description = "ALB ARN for the V2 VPC Link integrations."
  type        = string
}

variable "alb_secret_header" {
  description = "Secret header name and value to be sent to the ALB on every request."
  type        = list(string)
}

variable "cache_cluster_enabled" {
  description = "Enable or disable the API Gateway cache cluster."
  type        = bool
  default     = false
}

variable "cache_cluster_size" {
  description = "The size of the cache cluster for the API Gateway."
  type        = string
  default     = "0.5"
}

variable "log_level" {
  description = "The log level for the API Gateway."
  type        = string
  default     = "INFO"
}

variable "long_cache_ttl" {
  description = "The TTL for long cache duration in seconds."
  type        = number
  default     = 3600
}

variable "uk_uncached_paths" {
  description = "List of API paths that should not be cached on the UK service."
  type        = set(string)
  default = [
    "exchange_rates",
    "healthcheck",
    "live_issues",
    "news",
    "search_references"
  ]
}

variable "xi_uncached_paths" {
  description = "List of API paths that should not be cached on the XI service."
  type        = set(string)
  default = [
    "green_lanes",
    "healthcheck",
    "search_references",
  ]
}

variable "cache_key_params" {
  description = "List of query string parameters to include in the cache key."
  type        = list(string)
  default = [
    "as_of",
    "country_code",
    "heading_code",
    "include",
    "limit",
    "page",
    "per_page",
    "filter.exclude_none",
    "filter.from_date",
    "filter.geographical_area_id",
    "filter.has_article",
    "filter.meursing_additional_code_id",
    "filter.simplified_procedural_code",
    "filter.to_date",
    "filter.type",
  ]
}
