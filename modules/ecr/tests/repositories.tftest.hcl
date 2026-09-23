mock_provider "aws" {
  # The KMS key ARN is computed, so a plan cannot know it. Give it a fixed
  # value so the runs can check that each repository uses the module's key.
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
}

run "creates_one_repository_per_application" {
  command = plan

  assert {
    condition = toset(keys(aws_ecr_repository.this)) == toset([
      "admin",
      "backend",
      "frontend",
      "database-backups",
      "database-replication",
      "fpo-search",
      "dev-hub",
      "identity",
      "ai-search-evaluation-suite",
      "mcp",
    ])
    error_message = "There must be exactly one repository for each application in local.applications."
  }
}

run "names_repositories_with_application_and_environment" {
  command = plan

  assert {
    condition     = aws_ecr_repository.this["backend"].name == "tariff-backend-staging"
    error_message = "Repository names must be tariff-<application>-<environment>."
  }

  assert {
    condition     = aws_ecr_repository.this["fpo-search"].name == "tariff-fpo-search-staging"
    error_message = "Repository names must be tariff-<application>-<environment> for hyphenated application names too."
  }
}

run "makes_every_repository_safe_by_default" {
  command = plan

  assert {
    condition     = alltrue([for repository in aws_ecr_repository.this : repository.image_tag_mutability == "IMMUTABLE"])
    error_message = "Every repository must have immutable image tags."
  }

  assert {
    condition     = alltrue([for repository in aws_ecr_repository.this : repository.force_delete == false])
    error_message = "No repository may be force deleted while it still holds images."
  }

  assert {
    condition     = alltrue([for repository in aws_ecr_repository.this : repository.image_scanning_configuration[0].scan_on_push == true])
    error_message = "Every repository must scan images on push."
  }
}

run "encrypts_every_repository_with_the_module_kms_key" {
  command = plan

  assert {
    condition     = alltrue([for repository in aws_ecr_repository.this : repository.encryption_configuration[0].encryption_type == "KMS"])
    error_message = "Every repository must use KMS encryption."
  }

  assert {
    condition = alltrue([
      for repository in aws_ecr_repository.this :
      repository.encryption_configuration[0].kms_key == "arn:aws:kms:eu-west-2:123456789012:key/00000000-0000-0000-0000-000000000000"
    ])
    error_message = "Every repository must be encrypted with the KMS key that the module creates."
  }

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == true
    error_message = "The ECR KMS key must have key rotation enabled."
  }
}

run "enables_enhanced_scanning_for_all_repositories" {
  command = plan

  assert {
    condition     = aws_ecr_registry_scanning_configuration.this.scan_type == "ENHANCED"
    error_message = "The registry must use ENHANCED scanning."
  }

  assert {
    condition = alltrue([
      for rule in aws_ecr_registry_scanning_configuration.this.rule :
      rule.scan_frequency == "SCAN_ON_PUSH" &&
      alltrue([for filter in rule.repository_filter : filter.filter == "*" && filter.filter_type == "WILDCARD"])
    ])
    error_message = "The registry scanning rule must scan every repository on push."
  }
}
