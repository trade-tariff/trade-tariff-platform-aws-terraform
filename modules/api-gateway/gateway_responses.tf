resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "UNAUTHORIZED"
  status_code   = "401"

  response_templates = {
    "application/json" = jsonencode({
      errors = [
        {
          status = "401"
          title  = "Unauthorized"
          detail = "Authentication credentials were missing, incorrect or expired. Please sign up to the service to obtain valid credentials at https://hub.trade-tariff.service.gov.uk."
        }
      ]
    })
  }
}

resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "ACCESS_DENIED"
  status_code   = "403"

  response_templates = {
    "application/json" = jsonencode({
      errors = [
        {
          status = "403"
          title  = "Forbidden"
          detail = "You do not have permission to access this resource. Request access by signing up to the service at https://hub.trade-tariff.service.gov.uk."
        }
      ]
    })
  }
}
