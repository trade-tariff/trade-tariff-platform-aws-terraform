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
