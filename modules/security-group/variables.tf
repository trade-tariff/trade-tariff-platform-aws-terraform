variable "environment" {
  description = "Built environment."
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}
