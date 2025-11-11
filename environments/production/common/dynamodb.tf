resource "aws_dynamodb_table" "client_rate_limits" {
  name         = "client-rate-limits"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "clientId"

  attribute {
    name = "clientId"
    type = "S"
  }
}
