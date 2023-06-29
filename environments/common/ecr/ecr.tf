resource "aws_kms_key" "ecr_kms" {
  description         = "ECR KMS key"
  enable_key_rotation = true
}

# tfsec:ignore:aws-ecr-enforce-immutable-repository
resource "aws_ecr_repository" "trade_tariff_ecr_repo" {
  name                 = "trade-tariff-ecr-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = false
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_kms.arn
  }
}

output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.trade_tariff_ecr_repo.repository_url
}
