resource "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_name

  engine         = var.engine
  engine_mode    = var.engine_mode
  engine_version = var.engine_version

  allow_major_version_upgrade = true

  master_username = var.username
  master_password = random_password.master_password.result

  database_name = var.database_name

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.cluster_name}-final"

  storage_encrypted = var.encryption_at_rest
  kms_key_id        = try(aws_kms_key.this[0].arn, var.kms_key_id)

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.engine_mode == "provisioned" ? [1] : []
    content {
      max_capacity = var.max_capacity
      min_capacity = var.min_capacity
    }
  }

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.rds_private_subnet.name

  apply_immediately = var.apply_immediately

  tags = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  count      = var.cluster_instances
  identifier = "${var.cluster_name}-${count.index}"

  cluster_identifier   = aws_rds_cluster.this.id
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds_private_subnet.name

  instance_class = var.instance_class

  tags = var.tags
}

resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "_-"
}

resource "aws_db_subnet_group" "rds_private_subnet" {
  name       = "${var.cluster_name}-sg"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_kms_key" "this" {
  count               = local.create_kms_key
  description         = "KMS key for ${var.cluster_name}."
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
  tags                = var.tags
}
