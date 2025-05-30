terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
  }
}
