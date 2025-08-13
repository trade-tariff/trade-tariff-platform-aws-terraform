variable "environment" {
  description = "Build environment"
  type        = string
  default     = ""
}

variable "firehose_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream"
  type        = string
  default     = ""
}

variable "namespaces" {
  description = "List of AWS CloudWatch namespaces to stream metrics from"
  type        = list(string)
  default     = []
}
