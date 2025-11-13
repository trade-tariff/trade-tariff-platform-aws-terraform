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
      priority        = 10
      override_action = "none"
      excluded_rules  = ["NoUserAgent_HEADER", "SizeRestrictions_BODY"]
    },
    AWSManagedRulesAmazonIpReputationList = {
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesKnownBadInputsRuleSet = {
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesSQLiRuleSet = {
      priority        = 40
      override_action = "none"
      excluded_rules  = ["SQLi_QUERYARGUMENTS"]
    },
    AWSManagedRulesLinuxRuleSet = {
      priority        = 50
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesUnixRuleSet = {
      priority        = 60
      override_action = "none"
      excluded_rules  = []
    }
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
}

variable "assets_rate_based_rule" {
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
  description = "A rate-based rule specifically for assets defined in regex pattern set"
  default     = null
}

variable "ip_rate_url_based_rules" {
  type = list(object({
    name                  = string
    priority              = number
    limit                 = number
    action                = string
    search_string         = string
    positional_constraint = string
    regex_pattern_set_arn = string
  }))
  description = "A rate and url based rules tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span"
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
