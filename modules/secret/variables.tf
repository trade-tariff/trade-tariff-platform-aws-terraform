variable "secret_string" {
  description = "Value of the secret. Pass null to not populate a version"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ignore_secret_string_changes" {
  description = "If true, ignore drift on secret_string after creation (for console-managed configuration secrets)."
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the secret."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN with which to encrypt the secret."
  type        = string
}

variable "recovery_window" {
  description = "Recovery window in days for the secret."
  type        = string
}
