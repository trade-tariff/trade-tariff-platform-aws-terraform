variable "engine" {
  description = "Which caching engine to use. One of `redis` or `valkey`. Defaults to `redis`."
  type        = string
  default     = "redis"

  validation {
    condition     = contains(["redis", "valkey"], var.engine)
    error_message = "Engine must be either `redis` or `valkey`."
  }
}

variable "engine_version" {
  description = "Version of the caching engine to use."
  type        = string
}

variable "port" {
  description = "Port number."
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
  description = "Whether multi-az is enabled. Defaults to `true`."
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "Encryption at rest."
  type        = bool
  default     = false
}

variable "transit_encryption_enabled" {
  description = "Encryption in transit."
  type        = bool
  default     = false
}

variable "automatic_failover_enabled" {
  description = "Whether automatic failover is enabled. Defaults to `true`."
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Automatic upgrade of minor versions."
  type        = bool
  default     = true
}

variable "description" {
  description = "Cluster description"
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
  description = "Name of the subnet group to be used. Leave blank to have one be created."
  type        = string
  default     = null
}

variable "preferred_cache_cluster_azs" {
  description = "Availability zones to spread the nodes."
  type        = list(string)
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for Elasticache subnet group."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "auth_token" {
  description = "Password used to access the cluster. Requires `transit_encryption_enabled` to be `true`. Defaults to \"\", not set."
  type        = string
  sensitive   = true
  default     = ""
}

variable "auth_token_update_strategy" {
  description = <<-EOT
    Method to use in updating the auth token on a cluster.
    Can be one of `SET`, `ROTATE`, or `DELETE`:
      - `SET` should be used when setting a new auth token.
      - `ROTATE` is the default, for changing an auth token.
      - `DELETE` should be used, with an empty auth token, to remove password protection on a cluster.
  EOT
  type        = string
  default     = "ROTATE"

  validation {
    condition     = contains(["SET", "ROTATE", "DELETE"], var.auth_token_update_strategy)
    error_message = "Must be one of `SET`, `ROTATE`, or `DELETE`."
  }
}

variable "transit_encryption_mode" {
  description = "Whether to force transit encryption. `preferred` allows both, `required` forces it. Must use `preferred` on new replication groups."
  type        = string
  default     = "preferred"

  validation {
    condition     = contains(["preferred", "required"], var.transit_encryption_mode)
    error_message = "Must be one of `preferred` or `required`."
  }
}
