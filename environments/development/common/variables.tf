variable "environment" {
  type        = string
  description = "Build environment"
  default     = "development"
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

variable "aws_account_id" {
  description = "Development Account ID."
  type        = string
  default     = "844815912454"
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default = {
    Terraform = true
  }
}

variable "s3_tags" {
  description = "Tags"
  type        = map(string)
  default = {
    Project     = "trade-tariff"
    Environment = "development"
    Billing     = "TRN.HMR11896"
  }
}

variable "newrelic_license_key" {
  description = "License key for NewRelic."
  type        = string
  sensitive   = true
}

variable "backend_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the backend."
  type        = string
  sensitive   = true
}

variable "frontend_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the frontend."
  type        = string
  sensitive   = true
}

variable "duty_calculator_secret_key_base" {
  description = "Value of SECRET_KEY_BASE for the duty calculator."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sentry_dsn" {
  description = "Value of Backend Sentry DSN."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sync_email" {
  description = "Value of Tariff Sync email."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sync_host" {
  description = "Value of Tariff Sync host."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sync_password" {
  description = "Value of Tariff Sync password."
  type        = string
  sensitive   = true
}

variable "tariff_backend_sync_username" {
  description = "Value of Tariff Sync username."
  type        = string
  sensitive   = true
}

variable "tariff_backend_oauth_id" {
  description = "Value of Tariff Backend OAuth ID."
  type        = string
  sensitive   = true
}

variable "tariff_backend_oauth_secret" {
  description = "Value of Tariff Backend OAuth secret."
  type        = string
  sensitive   = true
}
