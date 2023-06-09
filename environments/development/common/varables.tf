variable "environment" {
  type        = string
  description = "Build environment"
  default     = "development"
}

variable "cidr_block" {
  description = "Vpc Cidr Block"
  type        = string
  default     = "10.0.0.0/16"
}

# variable "region" {
#   type    = string
#   default = "eu-west-2"
# }

# variable "aws_account_id" {
#   description = "Development Account ID."
#   type        = string
#   default     = "844815912454"
# }
