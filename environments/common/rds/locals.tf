locals {
  master_username = "${random_string.prefix.result}${random_string.master_username.result}"

  tags = merge(
    {
      Relation = "RDS Instance ${var.name}"
    },
    var.tags,
  )
}
