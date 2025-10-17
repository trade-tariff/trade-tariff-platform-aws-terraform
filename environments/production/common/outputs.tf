output "slack_topic_arn" {
  description = "The ARN of the SNS topic for Slack notifications"
  value       = module.notify_slack.slack_topic_arn
}
