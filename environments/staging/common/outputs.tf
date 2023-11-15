output "hosted_zone_name_servers" {
  description = "Name servers."
  value       = data.aws_route53_zone.this.name_servers
}

output "sandbox_hosted_zone_name_servers" {
  description = "Sandbox Name servers."
  value       = aws_route53_zone.sandbox.name_servers
}
