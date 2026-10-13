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
  engine_version     = "16.4"
  instance_type      = "db.t4g.micro"
  private_subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111"]
  secret_kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
}

run "tags_the_connection_string_secret_with_the_given_tags" {
  command = plan

  variables {
    tags = { Component = "devhub" }
  }

  assert {
    condition     = aws_secretsmanager_secret.this.tags["Component"] == "devhub"
    error_message = "The connection string secret must carry the tags that the caller gives."
  }

  assert {
    condition     = aws_db_instance.this.tags["Component"] == "devhub"
    error_message = "The database instance must carry the tags that the caller gives."
  }
}
