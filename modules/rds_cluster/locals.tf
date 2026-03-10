locals {
  engines = {
    "aurora-postgresql" = "postgres"
    "aurora-mysql"      = "mysql"
  }

  engine = local.engines[var.engine]

  options = (
    var.engine == "mysql" ? "?reconnect=true&useSSL=true" : ""
  )

  rw_string = (
    "${local.engine}://${var.username}:${random_password.master_password.result}@${aws_rds_cluster.this.endpoint}/${aws_rds_cluster.this.database_name}${local.options}"
  )

  ro_string = (
    "${local.engine}://${var.username}:${random_password.master_password.result}@${aws_rds_cluster.this.reader_endpoint}/${aws_rds_cluster.this.database_name}${local.options}"
  )

  create_kms_key = (
    var.encryption_at_rest == true && var.kms_key_id == null ? 1 : 0
  )

  engine_major_version = split(".", var.engine_version)[0]

  aurora_postgres_cluster_parameter_group_family = (
    var.engine == "aurora-postgresql" ? "aurora-postgresql${local.engine_major_version}" : null
  )
}
