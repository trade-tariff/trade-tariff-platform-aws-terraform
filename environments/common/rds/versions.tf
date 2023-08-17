terraform {
  required_version = "1.5.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.3"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
  }
}
