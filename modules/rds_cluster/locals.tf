locals {
  engine  = var.engine == "mysql" ? "mysql2" : var.engine
  options = var.engine == "mysql" ? "?reconnect=true&useSSL=true" : ""
  rw_string = (
    "${local.engine}://${var.username}:${random_password.master_password.result}@${aws_rds_cluster.this.endpoint}/${aws_rds_cluster.this.database_name}${local.options}"
  )
  ro_string = (
    "${local.engine}://${var.username}:${random_password.master_password.result}@${aws_rds_cluster.this.reader_endpoint}/${aws_rds_cluster.this.database_name}${local.options}"
  )
}
