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
