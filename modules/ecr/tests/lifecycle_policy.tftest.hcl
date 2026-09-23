mock_provider "aws" {}

variables {
  environment = "production"
}

run "creates_lifecycle_policy_for_every_application_that_enables_it" {
  command = plan

  assert {
    condition     = toset(keys(aws_ecr_lifecycle_policy.expire_untagged_images_policy)) == toset(keys(aws_ecr_repository.this))
    error_message = "Every application with lifecycle_policy = true must get a lifecycle policy."
  }

  assert {
    condition     = aws_ecr_lifecycle_policy.expire_untagged_images_policy["backend"].repository == "tariff-backend-production"
    error_message = "The lifecycle policy must target the repository named tariff-<application>-<environment>."
  }
}

run "keeps_production_images_by_release_tag_first" {
  command = plan

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["backend"].policy).rules[0].rulePriority == 1
    error_message = "The release image rule must have priority 1."
  }

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["backend"].policy).rules[0].selection.tagPrefixList == ["release"]
    error_message = "The first rule must only count images tagged with the release prefix."
  }

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["backend"].policy).rules[0].selection.countNumber == 15
    error_message = "backend must keep its last 15 production images."
  }

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["database-backups"].policy).rules[0].selection.countNumber == 5
    error_message = "database-backups must keep its last 5 production images."
  }
}

run "expires_untagged_images_after_fourteen_days" {
  command = plan

  assert {
    condition = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["frontend"].policy).rules[1].selection == {
      tagStatus   = "untagged"
      countType   = "sinceImagePushed"
      countUnit   = "days"
      countNumber = 14
    }
    error_message = "The second rule must expire untagged images 14 days after they are pushed."
  }
}

run "keeps_development_images_last" {
  command = plan

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["frontend"].policy).rules[2].rulePriority == 3
    error_message = "The development image rule must have the lowest priority (3), because a tagStatus of any rule must be last."
  }

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["frontend"].policy).rules[2].selection.tagStatus == "any"
    error_message = "The development image rule must count all images."
  }

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.expire_untagged_images_policy["frontend"].policy).rules[2].selection.countNumber == 30
    error_message = "frontend must keep its last 30 development images."
  }
}

run "outputs_a_repository_url_for_every_application" {
  command = plan

  assert {
    condition     = toset(keys(output.repository_urls)) == toset(keys(aws_ecr_repository.this))
    error_message = "repository_urls must have one entry for each repository."
  }
}
