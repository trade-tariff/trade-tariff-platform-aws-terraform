locals {
  rw_string = (
    "postgres://${var.username}:${random_password.master_password.result}@${aws_rds_cluster.this.endpoint}/${aws_rds_cluster.this.database_name}"
  )

  ro_string = (
    "postgres://${var.username}:${random_password.master_password.result}@${aws_rds_cluster.this.reader_endpoint}/${aws_rds_cluster.this.database_name}"
  )

  create_kms_key = (
    var.encryption_at_rest == true && var.kms_key_id == null ? 1 : 0
  )
}
