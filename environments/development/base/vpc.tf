module "vpc" {
  source = "github.com/trade-tariff/terraform-aws-vpc?ref=0ea859dd659701e6e8dda61e61c47629eeda5ba3"

  name = "trade-tariff-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.availability_zone
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  single_nat_gateway   = true

  tags = local.tags
}
