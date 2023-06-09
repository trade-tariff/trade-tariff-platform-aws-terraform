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
  value       = try(module.vpc.vpc_id.id[0].id, null)
}
