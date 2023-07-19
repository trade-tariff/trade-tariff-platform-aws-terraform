output "region" {
  description = "AWS region"
  value       = var.region
}

output "public_subnet_id" {
  description = "subnet id"
  value       = module.vpc.public_subnets
}

output "private_subnets_id" {
  description = "subnet id"
  value       = module.vpc.private_subnets
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_dns_namespace_id" {
  description = "ID of the private DNS namespace."
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "private_dns_namespace_arn" {
  description = "ARN of the private DNS namespace."
  value       = aws_service_discovery_private_dns_namespace.this.arn
}

output "private_dns_namespace_hosted_zone_id" {
  description = "ID of the Route 53 zone for the private DNS namespace."
  value       = aws_service_discovery_private_dns_namespace.this.hosted_zone
}
