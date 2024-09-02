variable "environment" {
  description = "Environment name."
  type        = string
}

variable "validation_timeout" {
  description = "How long to wait for a certificate to be issued, default max 45m"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Domain name to create certificate for."
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the hosted zone."
  type        = string
}

variable "subject_alternative_names" {
  description = "List of additional domains to be added to the certificate."
  type        = list(string)
  default     = []
}
