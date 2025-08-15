variable "environment" {
  description = "Build environment"
  type        = string
}

variable "firehose_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream"
  type        = string
}

variable "namespaces" {
  description = "List of CloudWatch namespaces to stream metrics from"
  type        = list(string)
  default     = []
}
