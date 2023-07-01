terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4" # Don't upgrade to 5.x.x yet
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
  }
}

provider "aws" {
  region = var.region
}
