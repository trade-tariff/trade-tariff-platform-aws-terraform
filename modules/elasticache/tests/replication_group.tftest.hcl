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

run "creates_subnet_group_when_no_name_is_given" {
  command = plan

  assert {
    condition     = length(aws_elasticache_subnet_group.this) == 1
    error_message = "A subnet group must be created when subnet_group_name is null."
  }

  assert {
    condition     = aws_elasticache_replication_group.this.subnet_group_name == "test-redis-subnet-group"
    error_message = "The replication group must use the subnet group that the module creates."
  }
}

run "uses_existing_subnet_group_when_name_is_given" {
  command = plan

  variables {
    subnet_group_name = "existing-subnet-group"
  }

  assert {
    condition     = length(aws_elasticache_subnet_group.this) == 0
    error_message = "No subnet group must be created when subnet_group_name is set."
  }

  assert {
    condition     = aws_elasticache_replication_group.this.subnet_group_name == "existing-subnet-group"
    error_message = "The replication group must use the subnet group name that the caller gives."
  }
}

run "omits_auth_settings_without_transit_encryption" {
  command = plan

  variables {
    transit_encryption_enabled = false
    auth_token                 = "a-token-that-must-not-be-sent"
  }

  # auth_token is Optional only, so a null value is known at plan time.
  # transit_encryption_mode and auth_token_update_strategy are Optional and
  # Computed. A null value for them is unknown at plan time, so this run
  # cannot assert on them.
  assert {
    condition     = nonsensitive(aws_elasticache_replication_group.this.auth_token == null)
    error_message = "auth_token must not be sent when transit encryption is disabled."
  }
}

run "sets_auth_settings_with_transit_encryption" {
  command = plan

  variables {
    transit_encryption_enabled = true
    transit_encryption_mode    = "required"
    auth_token                 = "a-valid-test-token-of-32-characters"
  }

  assert {
    condition     = aws_elasticache_replication_group.this.auth_token_update_strategy == "ROTATE"
    error_message = "auth_token_update_strategy must default to ROTATE when transit encryption is enabled."
  }

  assert {
    condition     = aws_elasticache_replication_group.this.transit_encryption_mode == "required"
    error_message = "transit_encryption_mode must pass through when transit encryption is enabled."
  }
}

run "rejects_unknown_engine" {
  command = plan

  variables {
    engine = "memcached"
  }

  expect_failures = [
    var.engine,
  ]
}

run "rejects_unknown_transit_encryption_mode" {
  command = plan

  variables {
    transit_encryption_mode = "optional"
  }

  expect_failures = [
    var.transit_encryption_mode,
  ]
}
