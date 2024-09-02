variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

variable "environment" {
  description = "Build environment"
  type        = string
}
