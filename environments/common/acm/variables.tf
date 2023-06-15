variable "environment" {
  description = "A map of tags to add to all resources"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = ""
}

variable "alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate"
  type        = string
  default     = ""
}

variable "validation_method" {
  description = "method to use for validation DNS or EMAIL are valid"
  type        = string
  default     = "DNS"
}

variable "private_zone" {
  description = "is private zone"
  type        = string
  default     = false
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
