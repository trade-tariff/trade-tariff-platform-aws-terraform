terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Terraform   = true
      Project     = "trade-tariff"
      Environment = "production"
      Stack       = basename(path.cwd)
      Region      = "eu-west-2"
      BillingCode = "HMR:OTT"
    }
  }
}
