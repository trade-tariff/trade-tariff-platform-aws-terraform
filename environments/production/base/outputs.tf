output "public_subnet_ids" {
  description = "A list of the VPC's public subnets."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "A list of the VPC's private subnets."
  value       = module.vpc.private_subnets
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets_cidr_blocks" {
  description = "A list of cidr_blocks of private subnets."
  value       = module.vpc.private_subnets_cidr_blocks
}

output "s3_endpoint_prefix" {
  description = "Prefix list of S3 VPC endpoint to use with security groups."
  value       = aws_vpc_endpoint.s3.prefix_list_id
}
