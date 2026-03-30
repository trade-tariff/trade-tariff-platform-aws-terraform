data "aws_lambda_function" "api_gateway_authorizer" {
  function_name = "api-gateway-authorizer-${var.environment}-authorizer"
}

resource "aws_lambda_permission" "allow_api_gateway_authorizer_invoke" {
  statement_id  = "AllowExecutionFromApiGatewayAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.api_gateway_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.gateway.execution_arn}/authorizers/*"
}
