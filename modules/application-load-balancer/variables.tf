variable "alb_security_group_id" {
  description = "Application load balancer security group ID."
  type        = string
}

variable "tls_application_port" {
  description = "Port the application exposes on HTTPS."
  type        = string
  default     = 8443
}

variable "listening_port" {
  description = "Port on which the load balancer listens to."
  type        = string
  default     = 443
}

variable "certificate_arn" {
  description = "ARN of the default SSL server certificate."
  type        = string
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API."
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = string
  default     = 60
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(any)
}

variable "alb_name" {
  description = "The name of the alb"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to place the load balancer into."
  type        = string
}

variable "custom_header" {
  description = "Custom header required in all requests to the load balancer."
  type = object({
    name  = string
    value = string
  })
}

variable "services" {
  description = "Map of services to make ALB target groups and listener rules for."
  type = map(
    object({
      healthcheck_path     = string
      hosts                = optional(list(string))
      paths                = optional(list(string))
      priority             = number
      bypass_custom_header = optional(bool, false)
    })
  )
}

variable "http_services" {
  description = <<-EOT
    Map of services whose containers serve plain HTTP (not the in-container TLS
    on 8443 that `services` assumes). Used for upstream images that don't
    terminate TLS themselves (e.g. self-hosted Flagsmith). The ALB still
    listens on HTTPS:443 and terminates TLS; it forwards to an HTTP target
    group on `container_port`.
  EOT
  type = map(
    object({
      healthcheck_path = string
      container_port   = optional(number, 8000)
      hosts            = optional(list(string))
      paths            = optional(list(string))
      priority         = number
    })
  )
  default = {}
}

variable "gateway_services" {
  description = "Map of services to make ALB target groups and listener rules for routable from API Gateway."
  type = map(
    object({
      healthcheck_path = string
      hosts            = optional(list(string))
      paths            = optional(list(string))
      priority         = number
    })
  )
  default = {}
}

variable "enable_access_logs" {
  description = "Whether to enable access logs for ALB."
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "Name of the S3 bucket to send access logs to. Leave blank to have one created."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 object prefix for access log entries."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name for the application."
  type        = string
}
