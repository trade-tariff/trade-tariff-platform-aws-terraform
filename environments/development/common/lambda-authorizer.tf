data "archive_file" "apigw_authorizer" {
  type        = "zip"
  source_dir  = "../../../common/lambda/api-lambda-authorizer"
  output_path = "lambda_api_authorizer.zip"
}

module "apigw_authorizer" {
  source = "../../../modules/lambda"

  function_name      = "trade-tariff-apigw-authorizer-${var.environment}"
  filename           = "lambda_apigw_authorizer.zip"
  handler            = "index.handler"
  runtime            = "nodejs22.x"
  source_code_hash   = data.archive_file.apigw_authorizer.output_base64sha256
  memory_size        = 256
  timeout            = 10
  log_retention_days = 7

  environment_variables = {
    COGNITO_USER_POOL_ID = module.identity_cognito.user_pool_id
    REQUIRED_SCOPE       = "tariff/read"
  }
}

resource "aws_lambda_permission" "apigw_authorizer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.apigw_authorizer.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.gateway.rest_api_execution_arn}/*/*"
}
