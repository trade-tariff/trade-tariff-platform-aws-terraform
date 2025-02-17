terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.3"
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
