terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.3"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }
}
