terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform   = true
      Project     = "trade-tariff"
      Environment = var.environment
      Stack       = basename(path.cwd)
      Region      = var.region
      BillingCode = "HMR:OTT"
    }
  }
}
