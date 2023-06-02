resource "aws_dynamodb_table" "this" {
  name             = var.dynamedb_name
  hash_key         = var.hash_key
  billing_mode     = var.billing_mode
  stream_enabled   = var.stream_enabled 

  attribute {
    name = var.attribute_name
    type = "S"
  }

}

