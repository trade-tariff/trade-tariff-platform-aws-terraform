variable "environment" {
  description = "Build environment"
  type        = string
}

variable "firehose_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream"
  type        = string
}

variable "include_metric_filters" {
  description = "Map of inclusive metric filters. Use the namespace as the key and the list of metric names as the value."
  type        = map(list(string))
  default     = {}
}
