variable "secret_string" {
  description = "Value of the secret. Pass null to not populate a version"
  type        = string
  sensitive   = true
  default     = ""
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

variable "create_secret_version" {
  description = "Whether to create a secret version. Set to false to create a secret without a version."
  type        = bool
  default     = true
}
