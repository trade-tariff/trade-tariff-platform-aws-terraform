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


variable "authorizer_enabled" {
  description = "Enable a custom Lambda authorizer for protected API methods."
  type        = bool
  default     = false
}

variable "authorizer_name" {
  description = "Name for the API Gateway Lambda authorizer."
  type        = string
  default     = null
}

variable "authorizer_lambda_invoke_arn" {
  description = "API Gateway-compatible invoke ARN for the Lambda function used by the authorizer."
  type        = string
  default     = null
}

variable "authorizer_identity_source" {
  description = "Identity source expression for the Lambda authorizer."
  type        = string
  default     = "method.request.header.Authorization"
}

variable "authorizer_result_ttl_in_seconds" {
  description = "Authorizer cache TTL in seconds. Set to 0 to disable caching."
  type        = number
  default     = 0
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
    "chemical_substances",
    "description_intercepts",
    "exchange_rates",
    "healthcheck",
    "live_issues",
    "news",
    "search",
    "search_suggestions",
    "search_references"
  ]
}

variable "xi_uncached_paths" {
  description = "List of API paths that should not be cached on the XI service."
  type        = set(string)
  default = [
    "chemical_substances",
    "description_intercepts",
    "green_lanes",
    "healthcheck",
    "search",
    "search_suggestions",
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
    "fields",
    "fields.additional_code",
    "fields.additional_code_type",
    "fields.category_assessment",
    "fields.certificate",
    "fields.certificate_type",
    "fields.change",
    "fields.chapter",
    "fields.chemical",
    "fields.chemical_substance",
    "fields.commodity",
    "fields.definition",
    "fields.description_intercept",
    "fields.duty_expression",
    "fields.exact_search",
    "fields.exchange_rate",
    "fields.exchange_rate_collection",
    "fields.exchange_rate_file",
    "fields.exchange_rate_period",
    "fields.exchange_rate_period_list",
    "fields.exchange_rate_year",
    "fields.footnote",
    "fields.footnote_type",
    "fields.fuzzy_search",
    "fields.geographical_area",
    "fields.goods_nomenclature",
    "fields.green_lanes_faq_feedback",
    "fields.guide",
    "fields.heading",
    "fields.import_trade_summary",
    "fields.legal_act",
    "fields.live_issue",
    "fields.measure",
    "fields.measure_action",
    "fields.measure_component",
    "fields.measure_condition",
    "fields.measure_condition_code",
    "fields.measure_condition_component",
    "fields.measure_condition_permutation",
    "fields.measure_condition_permutation_group",
    "fields.measure_type",
    "fields.measurement_unit",
    "fields.measurement_unit_qualifier",
    "fields.monetary_exchange_rate",
    "fields.national_measurement_unit",
    "fields.news_collection",
    "fields.news_item",
    "fields.news_year",
    "fields.null_search",
    "fields.order_number",
    "fields.preference_code",
    "fields.quota_balance_event",
    "fields.quota_closed_and_transferred_event",
    "fields.quota_definition",
    "fields.quota_order_number",
    "fields.quota_order_number_origin",
    "fields.quota_order_number_origin_exclusion",
    "fields.rules_of_origin_article",
    "fields.rules_of_origin_link",
    "fields.rules_of_origin_origin_reference_document",
    "fields.rules_of_origin_proof",
    "fields.rules_of_origin_rule",
    "fields.rules_of_origin_rule_set",
    "fields.rules_of_origin_scheme",
    "fields.rules_of_origin_v2_rule",
    "fields.search_reference",
    "fields.search_suggestion",
    "fields.section",
    "fields.simplified_procedural_code_measure",
    "fields.subheading",
    "fields.suspension_legal_act",
    "fields.tariff_update",
    "fields.validity_period",
    "limit",
    "page",
    "per_page",
    "type",
    "code",
    "description",
    "order_number",
    "year",
    "month",
    "day",
    "name",
    "cas",
    "source",
    "excluded",
    "critical",
    "geographical_area_id",
    "goods_nomenclature_item_id",
    "status",
    "q",
    "query.letter",
    "filter.cas_rn",
    "filter.cus",
    "filter.exclude_none",
    "filter.from_date",
    "filter.geographical_area_id",
    "filter.goods_nomenclature_item_id",
    "filter.goods_nomenclature_sid",
    "filter.has_article",
    "filter.meursing_additional_code_id",
    "filter.simplified_procedural_code",
    "filter.status",
    "filter.to_date",
    "filter.type",
  ]
}
