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

variable "region" {
  description = "AWS Region to use. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "alb_name" {
  description = "The name of the alb"
  type        = string
  default     = "trade-tariff-alb"
}

variable "public_subnets_id" {
  description = "The name of the alb"
  type        = string
  default     = "VPC public subnet"
}

variable "vpc_id" {
  description = "The id of the vpc"
  type        = string
}
