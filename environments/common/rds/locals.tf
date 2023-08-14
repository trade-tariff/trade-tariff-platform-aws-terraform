locals {
  max_allocated_storage = var.max_allocated_storage <= var.allocated_storage || var.max_allocated_storage == null ? var.allocated_storage : var.max_allocated_storage
  master_username       = "${random_string.prefix.result}${random_string.master_username.result}"
  master_password       = random_password.master_password.result

  tags = merge(
    {
      Relation = "RDS Instance ${var.name}"
    },
    var.tags,
  )
}
