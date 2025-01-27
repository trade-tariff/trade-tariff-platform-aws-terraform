resource "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_name

  engine         = var.engine
  engine_mode    = var.engine_mode
  engine_version = var.engine_version

  master_username = var.username
  master_password = random_password.master_password.result

  database_name       = var.database_name
  skip_final_snapshot = true

  serverlessv2_scaling_configuration {
    max_capacity = 256
    min_capacity = 0
  }
}

resource "aws_rds_cluster_instance" "this" {
  count      = var.cluster_instances
  identifier = "${var.cluster_name}-${count.index}"

  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  instance_class = var.instance_class
}

resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "_-"
}
