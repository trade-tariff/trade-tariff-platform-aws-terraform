variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "development"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
}

variable "availability_zone" {
  description = "A list of AWS availability zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "enable_nat_gateway" {
  type    = string
  default = "true"
}

variable "enable_vpn_gateway" {
  type    = string
  default = "true"
}

variable "enable_dns_hostnames" {
  type    = string
  default = "true"
}
