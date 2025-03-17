variable "cloudwatch_logs_export_bucket" {
  type        = string
  default     = ""
  description = "Bucket to export logs"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Build environment"
}
