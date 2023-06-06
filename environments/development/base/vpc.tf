#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  source = "github.com/trade-tariff/terraform-aws-vpc?ref=0ea859dd659701e6e8dda61e61c47629eeda5ba3"

  name = "trade_tariff_development_vcp"
  cidr = var.cidr_block

  azs             = var.availability_zone
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
