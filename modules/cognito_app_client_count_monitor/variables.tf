variable "environment" {
  description = "Environment label (e.g. staging, production) — used in metric dimensions and resource names."
  type        = string
}

variable "user_pool_id" {
  description = "Cognito user pool ID whose app clients are counted."
  type        = string
}

variable "user_pool_arn" {
  description = "ARN of the Cognito user pool — scopes ListUserPoolClients."
  type        = string
}

variable "alarm_actions" {
  description = "SNS topic ARNs for alarm notifications (e.g. Slack notify topics)."
  type        = list(string)
}

variable "alarm_threshold" {
  description = "Alarm when app client count is at or above this value."
  type        = number
  default     = 800
}

variable "schedule_expression" {
  description = "EventBridge schedule for publishing the metric."
  type        = string
  default     = "rate(1 hour)"
}

variable "metric_namespace" {
  description = "CloudWatch namespace for the custom metric."
  type        = string
  default     = "TradeTariff/Identity"
}

variable "metric_name" {
  description = "CloudWatch metric name for app client count."
  type        = string
  default     = "AppClientCount"
}

variable "lambda_timeout_seconds" {
  description = "Lambda timeout — pagination must finish within this window."
  type        = number
  default     = 60
}

variable "log_retention_days" {
  description = "Retention for the Lambda log group."
  type        = number
  default     = 14
}
