terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Terraform   = true
      Project     = "trade-tariff"
      Environment = "development"
      Stack       = basename(path.cwd)
      Region      = "eu-west-2"
      BillingCode = "HMR:OTT"
    }
  }
}
