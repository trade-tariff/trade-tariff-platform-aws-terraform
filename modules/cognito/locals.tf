data "aws_region" "current" {}

locals {
  email_sending_account = var.email_configuration_set != null ? "DEVELOPER" : "COGNITO_DEFAULT"
}
