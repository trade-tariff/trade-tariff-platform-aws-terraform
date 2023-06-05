terraform {
  required_version = ">= 1.2.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.23"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-east-2"
}
