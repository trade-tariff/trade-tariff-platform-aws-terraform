variable "dynamobd_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are billed for read/write throughput and how you manage capacity. The valid values are PROVISIONED or PAY_PER_REQUEST"
  type        = string
}

variable "stream_enabled" {
  description = "enable Streaming"
  type        = string
}

variable "attribute_name" {
  description = "Name of the attribute"
  type        = string
}
