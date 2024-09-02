variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "allocated_storage" {
  description = "Storage to allocate initially to the instance in gibibytes (i.e. 2^30 bytes). Can autoscale."
  type        = number
  default     = 5
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for the instance. Defaults to `null` (no autoscaling)."
  type        = number
  default     = 1 # implicitly this is less than allocated_storage so autoscaling is disabled
}

variable "instance_type" {
  description = "Instance type for the database. See https://aws.amazon.com/rds/instance-types/"
  type        = string
}

variable "backup_retention_period" {
  description = "Amount of time, in days, (between 0 and 35) that backups should be retained for."
  type        = number
  default     = 30
}

variable "performance_insights_retention_period" {
  description = "Amount of time, in days, (minimum 7, maximum 731, or any multiple of 31) to retain performance insights data."
  type        = number
  default     = 31
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with this RDS instance."
  type        = list(string)
  default     = null
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled, eg: `09:46-10:16`"
  type        = string
}

variable "maintenance_window" {
  description = "The time window (in UTC) to perform maintenance in. Syntax: `ddd:hh24:mi-ddd:hh24:mi`, eg: `Mon:00:00-Mon:01:30`."
  type        = string
}

variable "name" {
  description = "Name of the database."
  type        = string
}

variable "engine" {
  description = "Database engine to use."
  type        = string
}

variable "engine_version" {
  description = "Version of the database engine to use."
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all taggable resources."
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Whether to protect the database from deletion. Defaults to `true`."
  type        = bool
  default     = true
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs"
  type        = list(string)
}

variable "secret_kms_key_arn" {
  description = "ARN of the KMS Key to use to encrypt the connection string secret."
  type        = string
}

variable "multi_az" {
  description = "If the RDS instance is multi-AZ."
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Name of the parameter group to use for the RDS instance."
  type        = string
}
