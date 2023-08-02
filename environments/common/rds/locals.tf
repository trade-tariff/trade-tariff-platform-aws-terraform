locals {
  max_allocated_storage = var.max_allocated_storage <= var.allocated_storage || var.max_allocated_storage == null ? var.allocated_storage : var.max_allocated_storage
  master_username       = "${random_string.prefix.result}${random_string.master_username.result}"
  master_password       = urlencode(jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["password"])

  tags = merge(
    {
      Relation = "RDS Instance ${var.name}"
    },
    var.tags,
  )
}
