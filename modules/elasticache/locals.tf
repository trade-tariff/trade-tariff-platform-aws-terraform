locals {
  subnet_group_name = var.create_subnet_group ? aws_elasticache_subnet_group.this[0].name : var.subnet_group_name
}
