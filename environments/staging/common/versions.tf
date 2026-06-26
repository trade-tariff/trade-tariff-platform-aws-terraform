terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }

    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.5"
    }

    newrelic = {
      source  = "newrelic/newrelic"
      version = ">= 3.78.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
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


provider "newrelic" {
  account_id = local.newrelic_account_id
  api_key    = local.newrelic_user_key
  region     = "EU"
}
