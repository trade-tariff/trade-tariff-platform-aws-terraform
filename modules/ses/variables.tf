variable "domain_name" {
  description = "Domain name to verify."
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID."
  type        = string
}

variable "email_receiver" {
  description = "Activate email receiver"
  type        = bool
}

variable "receiving_endpoint" {
  description = "Email Receiving endpoints"
  type        = string
  default     = "placeholder"
}

variable "ses_inbound_bucket" {
  description = "S3 bucket for email inbox"
  type        = string
  default     = "placeholder"
}

variable "ses_iam_role" {
  description = "SES iam role to access s3"
  type        = string
  default     = "placeholder"
}
