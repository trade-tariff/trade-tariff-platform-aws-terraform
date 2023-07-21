data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket = "terraform-state-${var.environment}-${var.aws_account_id}"
    key    = "base/terraform.tfstate"
    region = var.region
  }
}
