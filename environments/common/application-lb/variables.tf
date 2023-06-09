variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "region" {
  description = "AWS region. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

