terraform {
  required_version = "1.5.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4" # Don't upgrade to 5.x.x yet
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}
