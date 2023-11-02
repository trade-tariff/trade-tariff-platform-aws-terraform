output "hosted_zone_name_servers" {
  description = "Name servers."
  value       = aws_route53_zone.this.name_servers
}
