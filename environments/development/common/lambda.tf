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

  function_name    = "trade-tariff-identity-create-auth-challenge"
  filename         = "lambda_create_auth_challenge.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "ruby3.4"
  source_code_hash = data.archive_file.create_auth_challenge.output_base64sha256
  memory_size      = 512

  environment_variables = local.create_auth_challenge_configuration_secret_map

  additional_policy_arns = [aws_iam_policy.lambda_ses.arn]
}

module "define_auth_challenge" {
  source = "../../../modules/lambda"

  function_name    = "trade-tariff-identity-define-auth-challenge"
  filename         = "lambda_define_auth_challenge.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "ruby3.4"
  source_code_hash = data.archive_file.define_auth_challenge.output_base64sha256
  memory_size      = 512
}

module "verify_auth_challenge" {
  source = "../../../modules/lambda"

  function_name    = "trade-tariff-identity-verify-auth-challenge-response"
  filename         = "lambda_verify_auth_challenge_response.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "ruby3.4"
  source_code_hash = data.archive_file.verify_auth_challenge.output_base64sha256
  memory_size      = 512
}

data "aws_iam_policy_document" "lambda_ses" {
  statement {
    sid    = 1
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_ses" {
  name   = "lambda-ses-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_ses.json
}
