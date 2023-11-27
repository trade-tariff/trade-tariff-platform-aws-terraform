resource "aws_kms_key" "this" {
  description         = "ECR KMS key"
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/ecr-kms-key"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_ecr_repository" "this" {
  for_each             = toset(local.applications)
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
  for_each = toset(local.applications)

  repository = "tariff-${each.key}-${var.environment}"

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images."
      selection = {
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
      action = {
        type = "expire"
      }
    }]
  })

  depends_on = [
    aws_ecr_repository.this,
  ]
}

output "repository_urls" {
  description = "Map of ECR repository URLs, sorted by service."
  value = {
    for k in toset(local.applications) : k => aws_ecr_repository.this[k].repository_url
  }
}
