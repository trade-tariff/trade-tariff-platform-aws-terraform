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
  hash_key     = "CustomerApiKeyId" # Unique identifier for the API key
  range_key    = "FpoId"            # Localized in dynamodb for each SCP customer that logs in

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
