mock_provider "aws" {}

variables {
  engine_version          = "7.1"
  replication_group_id    = "test-redis"
  description             = "Test replication group"
  num_node_groups         = "1"
  replicas_per_node_group = "1"
  node_type               = "cache.t3.small"
  maintenance_window      = "sun:05:00-sun:06:00"
  snapshot_window         = "03:00-04:00"
  parameter_group_name    = "default.redis7"
  subnet_ids              = ["subnet-00000000000000000", "subnet-11111111111111111"]
}

run "has_no_tags_by_default" {
  command = plan

  assert {
    condition     = length(aws_elasticache_replication_group.this.tags) == 0
    error_message = "The replication group must have no module tags when the caller gives none."
  }
}

run "tags_every_resource_with_the_given_tags" {
  command = plan

  variables {
    tags = { Component = "backend", Service = "uk" }
  }

  assert {
    condition     = aws_elasticache_replication_group.this.tags == tomap({ Component = "backend", Service = "uk" })
    error_message = "The replication group must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_elasticache_subnet_group.this[0].tags == tomap({ Component = "backend", Service = "uk" })
    error_message = "The subnet group that the module creates must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_cloudwatch_log_group.slow_lg.tags == tomap({ Component = "backend", Service = "uk" })
    error_message = "The slow log group must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_cloudwatch_log_group.engine_lg.tags == tomap({ Component = "backend", Service = "uk" })
    error_message = "The engine log group must carry the tags that the caller gives."
  }
}
