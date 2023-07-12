variable "secret_string" {
  description = "Value of the secret."
  type        = string
  sensitive   = true
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
