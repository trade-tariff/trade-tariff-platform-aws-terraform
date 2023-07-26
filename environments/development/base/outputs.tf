output "region" {
  description = "AWS region"
  value       = var.region
}

output "public_subnet_ids" {
  description = "A list of the VPC's public subnet IDs."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "A list of the VPC's private subnet IDs."
  value       = module.vpc.private_subnets
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}
