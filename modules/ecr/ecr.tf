resource "aws_kms_key" "this" {
  description         = "ECR KMS key"
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/ecr-kms-key"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_ecr_repository" "this" {
  for_each             = local.applications
  name                 = "tariff-${each.key}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = false
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.this.arn
  }
}

resource "aws_ecr_lifecycle_policy" "expire_untagged_images_policy" {
  for_each = {
    for k, v in local.applications : k => v
    if v.lifecycle_policy
  }

  repository = "tariff-${each.key}-${var.environment}"

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.production_images_to_keep} production images."
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["release"]
          countType     = "imageCountMoreThan"
          countNumber   = each.value.production_images_to_keep
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last ${each.value.development_images_to_keep} development images."
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = each.value.development_images_to_keep
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  depends_on = [
    aws_ecr_repository.this,
  ]
}

output "repository_urls" {
  description = "Map of ECR repository URLs, sorted by service."
  value = {
    for k, v in local.applications : k => aws_ecr_repository.this[k].repository_url
  }
}
