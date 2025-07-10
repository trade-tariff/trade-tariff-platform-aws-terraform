variable "create_distribution" {
  description = "Controls if CloudFront distribution should be created"
  type        = bool
  default     = true
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
  default     = null
}

variable "comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = null
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2. The default is http2."
  type        = string
  default     = "http2"
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = null
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = null
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = true
}

variable "web_acl_id" {
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = null
}

variable "origin" {
  description = "One or more origins for this distribution (multiples allowed)."
  type        = any
  default     = null
}

variable "origin_group" {
  description = "One or more origin_group for this distribution (multiples allowed)."
  type        = any
  default     = {}
}

variable "viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type        = any
  default = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

variable "geo_restriction" {
  description = "The restriction configuration for this distribution (geo_restrictions)"
  type        = any
  default     = {}
}

variable "logging_config" {
  description = "The logging configuration that controls how logs are written to your distribution (maximum one)."
  type        = any
  default     = {}
}

variable "custom_error_response" {
  description = "One or more custom error response elements"
  type        = any
  default     = {}
}

variable "cache_behaviors" {
  description = "List of cache behaviors in order of precedence (most specific first). Leave path_pattern empty when configuring the default behavior"
  type = list(object({
    name                       = string
    path_pattern               = optional(string)
    target_origin_id           = string
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    cache_policy_id            = string
    origin_request_policy_id   = string
    response_headers_policy_id = string

    # Optional fields with defaults
    allowed_methods           = optional(list(string), ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"])
    cached_methods            = optional(list(string), ["GET", "HEAD"])
    compress                  = optional(bool, true)
    field_level_encryption_id = optional(string)
    smooth_streaming          = optional(bool)
    trusted_signers           = optional(list(string))

    # Legacy TTL settings (usually not needed with cache policies)
    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 0)
    max_ttl     = optional(number, 0)

    # Function associations
    function_association = optional(map(object({
      function_arn = string
    })), {})

    # Lambda function associations
    lambda_function_association = optional(map(object({
      lambda_arn   = string
      include_body = optional(bool)
    })), {})
  }))

  default = []
}

variable "route53_zone_id" {
  description = "The ID of the Route53 zone where to create the Cloudfront alias CNAME records"
  type        = string
  default     = null
}

variable "health_check_id" {
  description = "The health check the record should be associated with."
  type        = string
  default     = null
}

variable "create_alias" {
  description = "Whether to create a Route 53 A record."
  type        = bool
  default     = false
}

variable "create_cname" {
  description = "Whether to create a Route 53 CNAME record."
  type        = bool
  default     = false
}
