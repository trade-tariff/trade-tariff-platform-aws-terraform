variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

variable "environment" {
  description = "Build environment"
  type        = string
}

variable "region" {
  description = "AWS region. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}
