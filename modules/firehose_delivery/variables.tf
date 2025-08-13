variable "environment" {
  description = "Environment name"
  type        = string
  default     = ""
}

variable "newrelic_datacenter" {
  description = "US or EU datacenter ('US' or 'EU')"
  type        = string
  default     = "EU"
}

variable "newrelic_license_key" {
  description = "New Relic ingest license key"
  type        = string
  sensitive   = true
}

variable "s3_backup_bucket" {
  description = "ARN of the S3 bucket for failed Firehose metrics"
  type        = string
}
