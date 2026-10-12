mock_provider "aws" {
  # The KMS key ARN is computed, so a plan cannot know it. Give it a fixed
  # value so the repositories can use the module's key.
  override_resource {
    target          = aws_kms_key.this
    override_during = plan
    values = {
      arn    = "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
      key_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  environment = "staging"
  tags        = { Project = "trade-tariff", Component = "shared" }
}

run "tags_the_kms_key_with_the_given_tags" {
  command = plan

  assert {
    condition     = aws_kms_key.this.tags == tomap({ Project = "trade-tariff", Component = "shared" })
    error_message = "The KMS key must carry the tags that the caller gives."
  }
}

run "keeps_the_given_tags_on_every_repository" {
  command = plan

  assert {
    condition     = alltrue([for repository in aws_ecr_repository.this : repository.tags["Project"] == "trade-tariff"])
    error_message = "Every repository must keep the tags that the caller gives."
  }
}

run "sets_the_component_of_each_repository_from_its_application" {
  command = plan

  assert {
    condition     = aws_ecr_repository.this["frontend"].tags["Component"] == "frontend"
    error_message = "The frontend repository must have Component=frontend, not the shared value from the caller."
  }

  assert {
    condition     = aws_ecr_repository.this["dev-hub"].tags["Component"] == "devhub"
    error_message = "The dev-hub repository must have Component=devhub."
  }

  assert {
    condition = alltrue([
      aws_ecr_repository.this["database-backups"].tags["Component"] == "backend",
      aws_ecr_repository.this["database-replication"].tags["Component"] == "backend",
      aws_ecr_repository.this["ai-search-evaluation-suite"].tags["Component"] == "backend",
    ])
    error_message = "The database and search evaluation repositories must have Component=backend."
  }
}

run "uses_only_the_documented_components" {
  command = plan

  assert {
    condition = alltrue([
      for repository in aws_ecr_repository.this :
      contains(["admin", "backend", "devhub", "frontend", "fpo-search", "identity", "mcp"], repository.tags["Component"])
    ])
    error_message = "Every repository must use a Component value from the documented list."
  }
}
