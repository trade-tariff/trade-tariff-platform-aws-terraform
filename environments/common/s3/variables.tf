variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "development"
}

variable "project" {
  description = "The name of the project"
  type        = string
  default     = "trade-tariff"
}

variable "s3_tags" {
  description = "Tags"
  type        = map(string)
}

variable "aws_account_id" {
  description = "Development Account ID."
  type        = string
  default     = "844815912454"
}
