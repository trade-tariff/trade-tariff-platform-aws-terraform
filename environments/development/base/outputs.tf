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

output "vpc_cidr" {
  description = "VPC CIDR block for use with security groups."
  value       = module.vpc.vpc_cidr_block
}
