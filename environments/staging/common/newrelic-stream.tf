data "aws_secretsmanager_secret_version" "newrelic_configuration" {
  secret_id = module.newrelic_configuration.secret_arn
}
