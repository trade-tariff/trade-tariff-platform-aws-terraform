variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default = {
    Terraform = true
  }
}

variable "region" {
  description = "AWS Region to use. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Staging environment."
  type        = string
  default     = "staging"
}

variable "account_ids" {
  type = map(string)
  default = {
    "development" = "844815912454"
    "staging"     = "451934005581"
    "production"  = "382373577178"
  }
}
