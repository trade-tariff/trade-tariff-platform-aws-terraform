mock_provider "aws" {}

variables {
  name            = "test-secret"
  kms_key_arn     = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
  recovery_window = "7"
}

run "creates_no_version_when_secret_string_is_empty" {
  command = plan

  assert {
    condition     = length(aws_secretsmanager_secret_version.this) == 0
    error_message = "No secret version must be created when secret_string is the empty default."
  }
}

run "creates_version_when_secret_string_is_given" {
  command = plan

  variables {
    secret_string = "a-secret-value"
  }

  assert {
    condition     = length(aws_secretsmanager_secret_version.this) == 1
    error_message = "One secret version must be created when secret_string is given."
  }

  assert {
    condition     = nonsensitive(aws_secretsmanager_secret_version.this[0].secret_string == "a-secret-value")
    error_message = "The secret version must hold the secret_string that the caller gives."
  }
}

run "encrypts_secret_with_given_kms_key" {
  command = plan

  assert {
    condition     = aws_secretsmanager_secret.this.kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
    error_message = "The secret must be encrypted with the KMS key that the caller gives."
  }
}
