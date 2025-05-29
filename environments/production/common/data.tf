data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

data "aws_secretsmanager_secret_version" "backups_basic_auth" {
  secret_id = module.backups_basic_auth.secret_arn
}
