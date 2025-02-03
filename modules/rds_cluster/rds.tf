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

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.rds_private_subnet.name

  apply_immediately = true
}

resource "aws_rds_cluster_instance" "this" {
  count      = var.cluster_instances
  identifier = "${var.cluster_name}-${count.index}"

  cluster_identifier   = aws_rds_cluster.this.id
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds_private_subnet.name

  instance_class = var.instance_class
}

resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "_-"
}

resource "aws_db_subnet_group" "rds_private_subnet" {
  name       = "${var.cluster_name}-sg"
  subnet_ids = var.private_subnet_ids
}
