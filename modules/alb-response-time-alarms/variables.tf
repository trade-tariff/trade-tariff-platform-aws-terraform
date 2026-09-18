variable "environment" {
  description = "Environment name included in alarm descriptions."
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "ARN suffix of the load balancer that owns the target groups."
  type        = string
}

variable "target_groups" {
  description = "ALB target groups to alarm on, keyed by target group name."
  type = map(object({
    name       = string
    arn        = string
    arn_suffix = string
  }))
}

variable "alarm_actions" {
  description = "SNS topic ARNs notified when a response-time alarm fires."
  type        = list(string)
  default     = []
}

variable "default_threshold" {
  description = "Average TargetResponseTime threshold in seconds for target groups without an override."
  type        = number
  default     = 1.5
}

variable "thresholds" {
  description = "Per target-group average TargetResponseTime thresholds in seconds. Unlisted target groups use default_threshold."
  type        = map(number)
  default     = {}
}
