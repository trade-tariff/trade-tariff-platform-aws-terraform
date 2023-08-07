variable "port" {
  description = "Redis port number."
  type        = number
  default     = 6379
}

variable "replication_group_id" {
  description = "Name of the replication group."
  type        = string
}

variable "apply_immediately" {
  description = "Whether to apply changes to the replication group immediately (`true`), or to wait for the next maintenance window (`false`)."
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Redis multi-az configuration."
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "Encryption at rest."
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Encryption in transit."
  type        = bool
  default     = true
}

variable "automatic_failover_enabled" {
  description = "Redis automatic failover configuration."
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Automatic upgrade of minor versions."
  type        = bool
  default     = true
}

variable "description" {
  description = "Redis cluster description"
  type        = string
}

variable "num_node_groups" {
  description = "Number of node groups."
  type        = string
}

variable "replicas_per_node_group" {
  description = "Number of replicas per node group."
  type        = string
}

variable "node_type" {
  description = "Instance type, i.e. `cache.t3.small`."
  type        = string
}

variable "log_delivery_configuration" {
  type = list(object({
    destination_type = string
    destination      = string
    log_format       = string
    log_type         = string
  }))
  description = "Log delivery configuration for redis cluster."
  default     = []

  validation {
    condition     = length(var.log_delivery_configuration) <= 2
    error_message = "You can set 2 targets at most for log delivery options."
  }
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

variable "parameter_group_name" {
  description = "Parameter group for replication group. For example, `default.redis7`."
  type        = string
}

variable "subnet_group_name" {
  description = "Name of the subnet group to be used."
  type        = string
  default     = null
}

variable "preferred_cache_cluster_azs" {
  description = "Availability zones to spread the nodes."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to all taggable resources."
  type        = map(string)
  default     = {}
}
