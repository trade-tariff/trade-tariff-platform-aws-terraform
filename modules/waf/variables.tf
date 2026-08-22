variable "name" {
  type        = string
  description = "A friendly name of the WebACL."
}

variable "scope" {
  type        = string
  description = "The scope of this Web ACL. Valid options: CLOUDFRONT, REGIONAL."
}

variable "managed_rules" {
  type = map(object({
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))

  description = "List of Managed WAF rules."

  default = {
    AWSManagedRulesCommonRuleSet = {
      priority        = 20
      override_action = "none"
      excluded_rules  = ["NoUserAgent_HEADER", "SizeRestrictions_BODY"]
    },
    AWSManagedRulesAmazonIpReputationList = {
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesKnownBadInputsRuleSet = {
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesSQLiRuleSet = {
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesLinuxRuleSet = {
      priority        = 60
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesUnixRuleSet = {
      priority        = 65
      override_action = "none"
      excluded_rules  = []
    },
  }
}

variable "managed_rule_path_exceptions" {
  type = list(object({
    name                 = string
    priority             = number
    managed_rule_group   = string
    managed_rule         = string
    label                = string
    excluded_uri_path    = string
    excluded_http_method = string
  }))

  description = "Managed rule matches to count and re-block everywhere except one exact URI path and HTTP method."
  default     = []

  validation {
    condition = alltrue([
      for exception in var.managed_rule_path_exceptions : try(
        contains(keys(var.managed_rules), exception.managed_rule_group) &&
        exception.priority > var.managed_rules[exception.managed_rule_group].priority,
        false,
      )
    ])

    error_message = "Each path exception must reference a configured managed rule group and have a priority greater than that group's priority."
  }
}

variable "ip_sets_rule" {
  type = list(object({
    name       = string
    priority   = number
    ip_set_arn = string
    action     = string
  }))
  description = "A rule to detect web requests coming from particular IP addresses or address ranges."
  default     = []
}

variable "ip_rate_based_rule" {
  type = object({
    name      = string
    priority  = number
    rpm_limit = number
    action    = string
    custom_response = object({
      response_code = number
      body_key      = string
      response_header = object({
        name  = string
        value = string
      })
    })
  })
  description = "A rate-based rule tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span"
  default     = null

  validation {
    condition     = var.ip_rate_based_rule == null || var.ip_rate_based_rule.priority >= 1
    error_message = "ip_rate_based_rule.priority must be >= 1, since allow_assets_from_rate_limit reserves priority - 1 immediately ahead of it."
  }
}

variable "ip_rate_url_based_rules" {
  type = list(object({
    name                  = string
    priority              = number
    limit                 = number
    action                = string
    search_string         = string
    positional_constraint = string
  }))
  description = "A rate and url based rules tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span"
  default     = []
}

variable "ip_set_rate_based_rules" {
  type = list(object({
    name       = string
    priority   = number
    limit      = number
    action     = string
    ip_set_arn = string
    custom_response = object({
      response_code = number
      body_key      = string
      response_header = object({
        name  = string
        value = string
      })
    })
  }))
  description = "Rate-based rules scoped to a specific IP set, tracking the rate of requests from addresses in that set and triggering the rule action when the rate exceeds the specified limit in any 1-minute window."
  default     = []
}

variable "filtered_header_rule" {
  type = object({
    header_types = list(string)
    priority     = number
    header_value = string
    action       = string
  })
  description = "HTTP header to filter . Currently supports a single header type and multiple header values."
  default = {
    header_types = []
    priority     = 1
    header_value = ""
    action       = "block"
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the WAFv2 ACL."
  default     = {}
}

variable "associate_alb" {
  type        = bool
  description = "Whether to associate an ALB with the WAFv2 ACL."
  default     = false
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB to be associated with the WAFv2 ACL."
  default     = ""
}

variable "group_rules" {
  type = list(object({
    name            = string
    arn             = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  description = "List of WAFv2 Rule Groups."
  default     = []
}

variable "default_action" {
  type        = string
  description = "The action to perform if none of the rules contained in the WebACL match."
  default     = "allow"
}

variable "bot_control_rule" {
  description = "Configuration for the AWS Bot Control managed rule group. Set enable_machine_learning to true to enable it or null to disable it; false is rejected because of hashicorp/terraform-provider-aws#48446. excluded_uri_prefixes must have 0 or at least 2 entries (or_statement requires a minimum of 2 statements). captcha_override_rules lists rule names whose default CAPTCHA action should be downgraded to a silent JS challenge."
  type = object({
    priority                = number
    override_action         = string
    inspection_level        = string
    enable_machine_learning = optional(bool)
    excluded_uri_prefixes   = list(string)
    captcha_override_rules  = optional(list(string), [])
  })
  default = null

  validation {
    condition     = var.bot_control_rule == null || length(var.bot_control_rule.excluded_uri_prefixes) != 1
    error_message = "excluded_uri_prefixes must contain 0 or at least 2 entries — or_statement requires a minimum of 2 statements."
  }

  validation {
    condition     = var.bot_control_rule == null || var.bot_control_rule.enable_machine_learning != false
    error_message = "enable_machine_learning must be true or null; false triggers hashicorp/terraform-provider-aws#48446."
  }
}

variable "uri_path_match_rules" {
  description = "Custom URI path match rules"
  type = list(object({
    name                  = string
    priority              = number
    action                = string # allow | block | count
    search_string         = string
    positional_constraint = string # CONTAINS | EXACTLY | STARTS_WITH | ENDS_WITH
  }))
  default = []
}

variable "header_allow_rules" {
  description = "Non-sensitive metadata for header-allow rules (name, priority, header_name). Sensitive header values are provided via the header_allow_values variable."
  type = list(object({
    name        = string
    priority    = number
    header_name = string
  }))
  default = []
}

variable "header_allow_values" {
  description = "Sensitive header values, keyed by rule name"
  type        = map(string)
  sensitive   = true
  default     = {}

  validation {
    condition = alltrue([
      for r in var.header_allow_rules : contains(keys(var.header_allow_values), r.name)
    ])
    error_message = "Every header_allow_rules[].name must have a corresponding entry in header_allow_values."
  }
}

variable "host_path_allow_rules" {
  description = "Rules that allow requests matching both a specific Host header value and a URI path. Use to grant domain-scoped path exceptions without affecting other domains sharing the same WAF."
  type = list(object({
    name                  = string
    priority              = number
    host                  = string
    path_search_string    = string
    positional_constraint = string # EXACTLY | STARTS_WITH | CONTAINS | ENDS_WITH
  }))
  default = []
}
