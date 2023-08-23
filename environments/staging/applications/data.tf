data "aws_caller_identity" "current" {}

data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket = "terraform-state-${var.environment}-${local.account_id}"
    key    = "base/terraform.tfstate"
    region = var.region
  }
}
