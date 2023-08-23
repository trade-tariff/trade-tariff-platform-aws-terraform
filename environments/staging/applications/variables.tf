variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "staging"
}

variable "region" {
  description = "AWS region. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}
