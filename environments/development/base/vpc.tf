data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.1.2"

  name = "trade-tariff-development-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "${local.region}a",
    "${local.region}b",
    "${local.region}c"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
}
