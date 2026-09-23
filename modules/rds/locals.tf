locals {
  max_allocated_storage = var.max_allocated_storage <= var.allocated_storage ? var.allocated_storage : var.max_allocated_storage
  master_username       = "${random_string.prefix.result}${random_string.master_username.result}"
  master_password       = random_password.master_password.result
  engine_major_version  = split(".", var.engine_version)[0]

  postgres_parameter_group_family = "postgres${local.engine_major_version}"

  cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(
    {
      Relation = "RDS Instance ${var.name}"
    },
    var.tags,
  )

  db_admin_string  = "postgres://${local.master_username}:${local.master_password}@${aws_db_instance.this.endpoint}/${var.name}"
  db_host_and_opts = "${aws_db_instance.this.endpoint}/${var.name}"
}
