mock_provider "aws" {
  # The endpoint is unknown at plan. A fixed value lets the runs check
  # how the module builds the connection strings.
  override_resource {
    target          = aws_db_instance.this
    override_during = plan
    values = {
      endpoint = "tariff.abc123.eu-west-2.rds.amazonaws.com:5432"
    }
  }
}

mock_provider "random" {
  override_resource {
    target          = random_string.prefix
    override_during = plan
    values = {
      result = "a"
    }
  }

  override_resource {
    target          = random_string.master_username
    override_during = plan
    values = {
      result = "bcdefgh"
    }
  }

  override_resource {
    target          = random_password.master_password
    override_during = plan
    values = {
      result = "test-password_16"
    }
  }
}

variables {
  environment        = "staging"
  name               = "Tariff"
  engine             = "postgres"
  engine_version     = "16.4"
  instance_type      = "db.t4g.micro"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111"]
  secret_kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
}

run "master_username_starts_with_a_letter_prefix" {
  command = plan

  # random_string.prefix has numeric = false so the username starts with a letter.
  assert {
    condition     = aws_db_instance.this.username == "abcdefgh"
    error_message = "The master username must be the letter prefix followed by the random username."
  }

  assert {
    condition     = random_string.prefix.numeric == false
    error_message = "The username prefix must not contain digits, because a database username must start with a letter."
  }
}

run "stores_the_admin_connection_string_in_secrets_manager" {
  command = plan

  assert {
    condition     = nonsensitive(aws_secretsmanager_secret_version.this.secret_string) == format("postgres://%s:%s@%s/%s", "abcdefgh", "test-password_16", "tariff.abc123.eu-west-2.rds.amazonaws.com:5432", "Tariff")
    error_message = "The secret must hold <engine>://<user>:<password>@<endpoint>/<name>."
  }
}

run "names_and_encrypts_the_secret" {
  command = plan

  variables {
    secret_recovery_window = 30
  }

  assert {
    condition     = aws_secretsmanager_secret.this.name == "tariff-connection-string"
    error_message = "The secret name must be the lower case database name followed by -connection-string."
  }

  assert {
    condition     = aws_secretsmanager_secret.this.kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
    error_message = "The secret must be encrypted with the KMS key that the caller gives."
  }

  assert {
    condition     = aws_secretsmanager_secret.this.recovery_window_in_days == 30
    error_message = "The secret recovery window must pass through."
  }
}

run "outputs_a_connection_string_without_credentials" {
  command = plan

  assert {
    condition     = output.userless_connection_string == "tariff.abc123.eu-west-2.rds.amazonaws.com:5432/Tariff"
    error_message = "userless_connection_string must be <endpoint>/<name> with no username or password."
  }
}
