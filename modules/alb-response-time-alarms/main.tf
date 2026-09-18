resource "aws_cloudwatch_metric_alarm" "long_response_times" {
  for_each = var.target_groups

  alarm_name          = "Long-response-times-${each.value.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  unit                = "Seconds"
  threshold           = lookup(var.thresholds, each.value.name, var.default_threshold)
  alarm_description   = "Long response times in ${var.environment} environment for target group ${each.value.name}"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = each.value.arn_suffix
  }
}
