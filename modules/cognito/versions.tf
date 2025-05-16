terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }
  }
}
