module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.1.2"

  name = "trade-tariff-development-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "${local.region}d",
    "${local.region}f",
  ]

  private_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  public_subnets = [
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24"
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
}
