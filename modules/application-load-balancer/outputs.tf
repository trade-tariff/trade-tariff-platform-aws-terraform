output "dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.application_load_balancer.dns_name
}

output "zone_id" {
  description = "Zone ID of the load balancer."
  value       = aws_lb.application_load_balancer.zone_id
}

output "arn_suffix" {
  description = "arn_suffix of the load balancer."
  value       = aws_lb.application_load_balancer.arn_suffix
}

output "target_groups" {
  description = "List of target groups."
  value = {
    for tg in aws_lb_target_group.trade_tariff_target_groups :
    tg.name => {
      name = tg.name,
      arn  = tg.arn
    }
  }
}

output "lb_arn" {
  description = "The ARN of the application load balancer."
  value       = aws_lb.application_load_balancer.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.application_load_balancer.dns_name
}

output "http_listener_arn" {
  value = aws_lb_listener.redirect_http.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.trade_tariff_listeners.arn
}
