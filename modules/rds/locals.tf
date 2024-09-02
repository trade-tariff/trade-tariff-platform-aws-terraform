locals {
  max_allocated_storage = var.max_allocated_storage <= var.allocated_storage ? var.allocated_storage : var.max_allocated_storage
  master_username       = "${random_string.prefix.result}${random_string.master_username.result}"
  master_password       = random_password.master_password.result

  tags = merge(
    {
      Relation = "RDS Instance ${var.name}"
    },
    var.tags,
  )

  db_engine        = var.engine == "mysql" ? "mysql2" : var.engine
  db_options       = var.engine == "mysql" ? "?reconnect=true&useSSL=true" : ""
  db_admin_string  = "${local.db_engine}://${local.master_username}:${local.master_password}@${aws_db_instance.this.endpoint}/${var.name}${local.db_options}"
  db_host_and_opts = "${aws_db_instance.this.endpoint}/${var.name}${local.db_options}"
}
