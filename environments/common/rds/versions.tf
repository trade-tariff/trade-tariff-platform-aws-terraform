terraform {
  required_version = ">= 1.4.6"
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
