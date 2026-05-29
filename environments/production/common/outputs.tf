output "slack_topic_arn" {
  description = "The ARN of the SNS topic for Slack notifications"
  value       = module.notify_slack.slack_topic_arn
}

output "slack_observability_topic_arn" {
  description = "The ARN of the SNS topic for Slack observability notifications"
  value       = module.notify_slack_observability.slack_topic_arn
}
