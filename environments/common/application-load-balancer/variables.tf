variable "environment" {
  type        = string
  description = "Build environment"
  default     = "development"
}

variable "alb_security_group_id" {
  description = "Application loadbalancer security group ID"
  type        = string
}

variable "application_port" {
  description = "application port"
  type        = string
  default     = 8080
}
variable "listening_port" {
  description = "Port on which the load balancer listens to"
  type        = string
  default     = 443
}

variable "certificate_arn" {
  description = "ARN of the default SSL server certificate"
  type        = string
}

variable "region" {
  description = "AWS region. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = string
  default     = "true"
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers"
  type        = string
  default     = "true"
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = string
  default     = 60
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = list(any)
}

variable "alb_name" {
  description = "The name of the alb"
  type        = string
  default     = "trade-tariff-alb-"
}

variable "vpc_id" {
  description = "The id of the vpc"
  type        = string
}
