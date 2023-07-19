locals {
  master_username       = "${random_string.prefix.result}${random_string.master_username.result}"
  max_allocated_storage = var.max_allocated_storage <= var.allocated_storage || var.max_allocated_storage == null ? var.allocated_storage : var.max_allocated_storage

  tags = merge(
    {
      Relation = "RDS Instance ${var.name}"
    },
    var.tags,
  )
}
