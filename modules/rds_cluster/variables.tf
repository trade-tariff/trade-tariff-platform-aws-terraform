variable "engine" {
  description = "Name of the database engine. One of `aurora-mysql`, `aurora-postgresql`, `mysql`, `postgres`."
  type        = string
}

variable "username" {
  type = string
}

variable "password" {
  default = ""
  type    = string
}

variable "managed_password" {
  default = false
  type    = bool
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
