variable "environment" {
  type        = string
  description = "Build environment"
  default     = "development"
}

variable "cidr_block" {
  description = "Vpc Cidr Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Name of the test Domain"
  type        = string
  default     = "transformtariff.co.uk"
}

variable "alb_security_group_id" {
  description = "Application loadbalancer security group ID"
  type        = string
}

variable "public_subnets_id" {
  description = "The public subnet on the VPC"
  type        = string
  Default     = data.terraform_remote_state.base.outputs.public_subnets_id
}

variable "public_vpc_id" {
  description = "The public subnet on the VPC"
  type        = string
  Default     = data.terraform_remote_state.base.outputs.public_vpc_id
}


variable "protocol" {
  description = "The protocol version"
  type        = string
  Default     = "HTTPS"
}

variable "application_port" {
  description = "application port"
  type        = string
  Default     = "HTTPS"
}



variable "target_type" {
  description = "Type of target that you must specify when registering targets with this target group."
  type        = string
  Default     = "ip"
}

variable "listening_port" {
  description = "Port on which the load balancer listens to"
  type        = string
  Default     = 443
}

variable "ssl_policy" {
  description = "Name of the SSL Policy for the listener"
  type        = any
  default     = [
    "ELBSecurityPolicy-TLS-1-2-2017-01",
    ]
}

variable "certificate_arn" {
  description = "ARN of the default SSL server certificate"
  type        = string
}
