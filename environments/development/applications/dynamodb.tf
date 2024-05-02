resource "aws_dynamodb_table" "lock" {
  for_each = toset(local.applications)

  name         = "${each.key}-lock-${local.account_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "customer_api_keys" {
  name         = "CustomerApiKeys"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "CustomerApiKeyId"
  range_key    = "FpoId"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "CustomerApiKeyId"
    type = "S"
  }

  attribute {
    name = "FpoId"
    type = "S"
  }

  tags = {
    customer = "fpo"
  }
}

resource "aws_dynamodb_table" "users" {
  name         = "Users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    customer = "fpo"
  }
}
