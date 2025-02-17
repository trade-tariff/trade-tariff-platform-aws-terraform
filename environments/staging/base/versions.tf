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
  region = "eu-west-2"

  default_tags {
    tags = {
      Terraform   = true
      Project     = "trade-tariff"
      Environment = "staging"
      Stack       = basename(path.cwd)
      Region      = "eu-west-2"
    }
  }
}
