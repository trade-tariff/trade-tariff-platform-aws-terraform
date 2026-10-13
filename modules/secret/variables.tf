variable "secret_string" {
  description = "Value of the secret. Leave empty to not populate a version."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_secret_version" {
  description = "Whether to populate a version. Leave null to populate one when secret_string is not empty. Set it to true when secret_string holds values that are unknown until apply, because Terraform cannot compare an unknown string to the empty string at plan time."
  type        = bool
  default     = null
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
  type        = number
}

variable "tags" {
  description = "A map of tags to add to the taggable resources in this module."
  type        = map(string)
  default     = {}
}
