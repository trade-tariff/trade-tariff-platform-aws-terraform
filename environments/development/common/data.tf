data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_secretsmanager_secret_version" "backups_basic_auth" {
  secret_id = module.backups_basic_auth.secret_arn
}

data "aws_secretsmanager_secret_version" "xi_api_configuration" {
  secret_id = module.backend_xi_api_configuration.secret_arn
}
