mock_provider "aws" {}
mock_provider "random" {}

variables {
  environment        = "staging"
  name               = "tariff"
  engine_version     = "16.4"
  instance_type      = "db.t4g.micro"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111"]
  secret_kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
}

run "disables_autoscaling_by_default" {
  command = plan

  variables {
    allocated_storage = 20
  }

  # A maximum equal to the allocated storage turns autoscaling off.
  assert {
    condition     = aws_db_instance.this.max_allocated_storage == 20
    error_message = "max_allocated_storage must equal allocated_storage when no larger maximum is given."
  }
}

run "enables_autoscaling_when_maximum_is_larger" {
  command = plan

  variables {
    allocated_storage     = 20
    max_allocated_storage = 100
  }

  assert {
    condition     = aws_db_instance.this.max_allocated_storage == 100
    error_message = "max_allocated_storage must pass through when it is larger than allocated_storage."
  }
}
