variable "environment" {
  description = "Built environment."
  type        = string
}

variable "region" {
  description = "AWS region. Defaults to `eu-west-2`."
  type        = string
  default     = "eu-west-2"
}

variable "aws_account_id" {
  description = "Development Account ID."
  type        = string
  default     = "844815912454"
}
