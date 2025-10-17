output "hosted_zone_name_servers" {
  description = "Name servers."
  value       = data.aws_route53_zone.this.name_servers
}

output "slack_topic_arn" {
  description = "The ARN of the SNS topic for Slack notifications"
  value       = module.notify_slack.slack_topic_arn
}
