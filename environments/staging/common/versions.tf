terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 5.98.0" # NOTE: Pushing to 5.98.0 causes issues with the AWS provider
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3"
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

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  default_tags {
    tags = {
      Terraform   = true
      Project     = "trade-tariff"
      Environment = var.environment
      Stack       = basename(path.cwd)
      Region      = "us-east-1"
      BillingCode = "HMR:OTT"
    }
  }
}
