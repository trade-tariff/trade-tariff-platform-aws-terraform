variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default = {
    Terraform = true
  }
}

variable "environment" {
  description = "Production environment."
  type        = string
  default     = "production"
}

variable "account_ids" {
  type = map(string)
  default = {
    "development" = "844815912454"
    "staging"     = "451934005581"
    "production"  = "382373577178"
  }
}
