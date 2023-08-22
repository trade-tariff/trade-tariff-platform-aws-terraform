variable "alb_security_group_id" {
  description = "Application load balancer security group ID."
  type        = string
}

variable "application_port" {
  description = "Port the application exposes."
  type        = string
  default     = 8080
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
