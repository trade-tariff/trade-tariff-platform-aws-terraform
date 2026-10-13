mock_provider "aws" {}

variables {
  name            = "test-secret"
  kms_key_arn     = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
  recovery_window = "7"
}

run "has_no_tags_by_default" {
  command = plan

  assert {
    condition     = length(aws_secretsmanager_secret.this.tags) == 0
    error_message = "The secret must have no module tags when the caller gives none."
  }
}

run "tags_the_secret_with_the_given_tags" {
  command = plan

  variables {
    tags = { Component = "backend" }
  }

  assert {
    condition     = aws_secretsmanager_secret.this.tags == tomap({ Component = "backend" })
    error_message = "The secret must carry the tags that the caller gives."
  }
}
