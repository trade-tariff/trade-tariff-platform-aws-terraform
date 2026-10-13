variable "environment" {
  description = "Build environment"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to the taggable resources in this module."
  type        = map(string)
  default     = {}
}
