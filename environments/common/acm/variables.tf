variable "environment" {
  description = "A map of tags to add to all resources"
  type        = string
}

variable "validation_timeout" {
  description = "How long to wait for a certificate to be issued, default max 45m"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "domain_name" {
  description = "Name of the test domain"
  type        = string
}
