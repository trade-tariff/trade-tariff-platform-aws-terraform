variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "region" {
  description = "AWS region. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "allowed_ingress_traffic" {
  description = "Ingress traffic allowed"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr_block" {
  description = "VPC Cidr Block"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
