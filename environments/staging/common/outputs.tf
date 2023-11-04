output "hosted_zone_name_servers" {
  description = "Name servers."
  value       = data.aws_route53_zone.this.name_servers
}
