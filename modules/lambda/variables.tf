variable "function_name" {
  description = "Name of the function"
  type        = string
}

variable "additional_policy_arns" {
  description = "List of ARNs of additional IAM policies to add to the IAM role"
  type        = list(string)
  default     = []
}

variable "filename" {
  description = "Name of the payload"
  type        = string
}

variable "handler" {
  description = "Function entrypoint"
  type        = string
}

variable "source_code_hash" {
  description = "base64 encoded SHA256 hash of the payload file"
  type        = string
}

variable "runtime" {
  description = "Function runtime identifier"
  type        = string
}

variable "memory_size" {
  description = "Memory limit in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}
