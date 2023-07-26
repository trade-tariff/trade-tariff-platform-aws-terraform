variable "group_name" {
  description = "Name of the replication group."
  type        = string
}

variable "apply_immediately" {
  description = "Whether to apply changes to the replication group immediately (`true`), or to wait for the next maintenance window (`false`)."
  type        = bool
  default     = false
}

variable "redis_version" {
  description = "Engine version to use."
  type        = string
}

variable "instance_type" {
  description = "Instance type, i.e. `cache.t3.small`."
  type        = string
}

variable "cloudwatch_log_group" {
  description = "Cloudwatch log group name for logs to flow into."
  type        = string
}

variable "maintenance_window" {
  description = "The weekly time range for maintenance periods on the cluster. Format: `ddd:hh22:mi-ddd:hh23:mi` (UTC). Minimum period must be 60 minutes. For example, `sun:05:00-sun:06:00`."
  type        = string
}

variable "snapshot_window" {
  description = "Daily time range during which ElastiCache will take a snapshot of the cache cluster. Minimum time of 60 minutes. For example: `05:00-06:00`."
  type        = string
}

variable "snapshot_retention_limit" {
  description = "Number of days of snapshots to retain. Defaults to `7`."
  type        = number
  default     = 7
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the group."
  type        = list(string)
  default     = null
}

variable "parameter_group" {
  description = "Parameter group for replication group. For example, `default.redis5.0`."
  type        = string
}
