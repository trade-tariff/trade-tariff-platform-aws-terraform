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
