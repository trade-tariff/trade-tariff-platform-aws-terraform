variable "engine" {
  description = "Name of the database engine. One of `aurora-mysql`, `aurora-postgresql`, `mysql`, `postgres`."
  type        = string
}

variable "username" {
  type = string
}

variable "engine_mode" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_instances" {
  default = 0
  type    = number
}

variable "instance_class" {
  type = string
}

variable "database_name" {
  description = "Name of the database."
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with this cluster."
  type        = list(string)
  default     = null
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs to associate with this cluster."
  type        = list(string)
}

variable "create_subnet_group" {
  description = "Whether to create a DB subnet group."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Existing DB subnet group name to use"
  type        = string
  default     = null
}

variable "max_capacity" {
  description = "Maximum capacity (ACUs). Defaults to `256`."
  type        = number
  default     = 256
}

variable "min_capacity" {
  description = "Minimum capacity (ACUs). Defaults to `0`."
  type        = number
  default     = 0
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately. Set to `true` when required. Defaults to `false`."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources in the module."
  type        = map(any)
  default     = {}
}

variable "encryption_at_rest" {
  description = "Whether to enable encryption at rest. Defaults to `false`."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ARN for encryption at rest."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection. Defaults to `true`."
  type        = bool
  default     = true
}

variable "cloudwatch_log_exports" {
  description = "A list of log types to export to CloudWatch Logs. Supported values: `postgresql`, `upgrade`, `iam-db-auth-error`."
  type        = list(string)
  default     = []

}

variable "db_cluster_parameter_group_name" {
  description = "The name of the DB cluster parameter group to associate with this cluster."
  type        = string
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights. Defaults to `true`."
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Amount of time, in days, (minimum 7, maximum 731, or any multiple of 31) to retain performance insights data."
  type        = number
  default     = 31
}

variable "database_insights_mode" {
  description = "The mode of Database Insights that is enabled for the instance. Valid values: standard, advanced."
  type        = string
  default     = "standard"
}

variable "instance_identifiers" {
  type        = list(string)
  description = "To avoid renames after a snapshot restore, we manually pass the cluster identifiers to have these identifiers reflected in terraform state and avoid alterations to the writer/reader instances."
  default     = []
}
