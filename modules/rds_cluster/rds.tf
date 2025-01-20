resource "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_name

  engine         = var.engine
  engine_mode    = var.engine_mode
  engine_version = var.engine_version

  master_username             = var.username
  master_password             = var.managed_password ? null : var.password
  manage_master_user_password = var.managed_password

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
