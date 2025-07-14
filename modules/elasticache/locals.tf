locals {
  subnet_group_name = var.subnet_group_name == null ? aws_elasticache_subnet_group.this[0].name : var.subnet_group_name
}
