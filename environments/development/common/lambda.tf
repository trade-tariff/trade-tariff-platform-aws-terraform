locals {
  create_auth_challenge_configuration_secret_value = try(data.aws_secretsmanager_secret_version.identity_create_auth_challenge_configuration.secret_string, "{}")
  create_auth_challenge_configuration_secret_map   = jsondecode(local.create_auth_challenge_configuration_secret_value)
}

data "archive_file" "create_auth_challenge" {
  type        = "zip"
  source_dir  = "../../../common/lambda/trade-tariff-identity-create-auth-challenge"
  output_path = "lambda_create_auth_challenge.zip"
}

data "archive_file" "define_auth_challenge" {
  type        = "zip"
  source_dir  = "../../../common/lambda/trade-tariff-identity-define-auth-challenge"
  output_path = "lambda_define_auth_challenge.zip"
}

data "archive_file" "verify_auth_challenge" {
  type        = "zip"
  source_dir  = "../../../common/lambda/trade-tariff-identity-verify-auth-challenge-response"
  output_path = "lambda_verify_auth_challenge_response.zip"
}

data "aws_secretsmanager_secret_version" "identity_create_auth_challenge_configuration" {
  secret_id = module.identity_create_auth_challenge_configuration.secret_arn
}

module "create_auth_challenge" {
  source = "../../../modules/lambda"

  function_name      = "trade-tariff-identity-create-auth-challenge"
  filename           = "lambda_create_auth_challenge.zip"
  handler            = "lambda_function.lambda_handler"
  runtime            = "ruby3.4"
  source_code_hash   = data.archive_file.create_auth_challenge.output_base64sha256
  memory_size        = 512
  log_retention_days = 7

  environment_variables = local.create_auth_challenge_configuration_secret_map

}

resource "aws_lambda_permission" "allow_cognito_invoke_create_auth_challenge" {
  statement_id  = "AllowExecutionFromCognitoCreateAuthChallenge"
  action        = "lambda:InvokeFunction"
  function_name = module.create_auth_challenge.lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "arn:aws:cognito-idp:${var.region}:${local.account_id}:userpool/${module.identity_cognito.user_pool_id}"
}

module "define_auth_challenge" {
  source = "../../../modules/lambda"

  function_name      = "trade-tariff-identity-define-auth-challenge"
  filename           = "lambda_define_auth_challenge.zip"
  handler            = "lambda_function.lambda_handler"
  runtime            = "ruby3.4"
  source_code_hash   = data.archive_file.define_auth_challenge.output_base64sha256
  memory_size        = 512
  log_retention_days = 7
}

resource "aws_lambda_permission" "allow_cognito_invoke_define_auth_challenge" {
  statement_id  = "AllowExecutionFromCognitoDefineAuthChallenge"
  action        = "lambda:InvokeFunction"
  function_name = module.define_auth_challenge.lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "arn:aws:cognito-idp:${var.region}:${local.account_id}:userpool/${module.identity_cognito.user_pool_id}"
}

module "verify_auth_challenge" {
  source = "../../../modules/lambda"

  function_name      = "trade-tariff-identity-verify-auth-challenge-response"
  filename           = "lambda_verify_auth_challenge_response.zip"
  handler            = "lambda_function.lambda_handler"
  runtime            = "ruby3.4"
  source_code_hash   = data.archive_file.verify_auth_challenge.output_base64sha256
  memory_size        = 512
  log_retention_days = 7
}

resource "aws_lambda_permission" "allow_cognito_invoke_verify_auth_challenge" {
  statement_id  = "AllowExecutionFromCognitoVerifyAuthChallenge"
  action        = "lambda:InvokeFunction"
  function_name = module.verify_auth_challenge.lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "arn:aws:cognito-idp:${var.region}:${local.account_id}:userpool/${module.identity_cognito.user_pool_id}"
}
