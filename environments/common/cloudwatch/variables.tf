variable "name" {
  description = "Name of the log group."
  type        = string
}

variable "region" {
  description = "AWS region to use."
  type        = string
}

variable "retention_in_days" {
  description = "Retention time in days. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653. Defaults to 0: that is, no expiry."
  type        = number
  default     = 0
}
